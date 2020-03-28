#!/usr/bin/env bash

set -e 

export PATH=/root/.local/bin:$PATH
export TERRAFORM_APPLIED=0
export TEMPDIR="/tmp/bitops_deployment"
export SECRETS_MGR=""
export IMG_REPO=""
export CURRENT_ENVIRONMENT=$(shyaml get-value environment.default < bitops.config.default.yaml)
export CLOUD_PLATFORM=""
export CI_PLATFORM=""
export CLOUD_PLATFORM=""
export DEPLOYMENT_DIR="$TEMPDIR"
export ENVROOT="$TEMPDIR"
export KUBE_CONFIG_FILE="$TEMPDIR/.kube/config"
export NAMESPACE=$(shyaml get-value helm.namespace < bitops.config.default.yaml)
export HELM_RELEASE_NAME=""
export APPLY=""
export PLAN=""
export DESTROY=""



if [ -e /opt/bitops_deployment ];
then
    echo "Creating temp directory: $TEMPDIR"
    if ! mkdir -p /tmp/bitops_deployment/.kube
    then 
        echo "failed to create: $TEMPDIR"
    else 
        echo "Successfully created $TEMPDIR "
    fi

    if ! cp -rf /opt/bitops_deployment/* /tmp/bitops_deployment/
    then 
        echo "failed to copy repo to: $TEMPDIR"
    else 
        echo "Successfully Copied repo to $TEMPDIR "
    fi
else
    echo "running locally"
    
    if ! mkdir -p /tmp/bitops_deployment/.kube;
    then 
        echo "failed to create: $TEMPDIR"
    else 
        echo "Successfully Created $TEMPDIR "
    fi

    if ! cp -rf /opt/deploy/* /tmp/bitops_deployment/
    then 
        echo "failed to copy repo to: $TEMPDIR"
    else 
        echo "Successfully Copied repo to $TEMPDIR "
    fi
fi


# Read the options from cli input
OPTIONS=$(getopt -o h --longoptions help,kubeconfig-base64:,terraform-directory:,environment:,terraform-plan:,terraform-apply:,terraform-destroy:,helm-charts:,ansible-directory:,ansible-playbooks:,external-helm-charts:,helm-charts-directory:,helm-s3-repo:,use-config-file: -n $0 -- "$@")
eval set -- "${OPTIONS}"


echo "options: ${OPTIONS}"
if [[ $# == 1 ]] ; then echo "No input provided! type ($0 --help) to see usage help" >&2 ; exit 1 ; fi

function usage() {
    echo "$0 <usage>"
    echo " "
    echo "options:"
    echo -e "--help \t Show options for this script"
    echo -e "--kubeconfig-base64 \t Pass in the environment variable containing the base64 contents of your kube config."
    echo -e "--terraform-directory \t The directory for the terraform deployment"
    echo -e "--helm-charts-directory \t The directory containing your helm charts. Use only if charts are in alternate location."
    echo -e "--helm-s3-repo \t The S3 Bucket containing the helm charts. Use the format: <NAME>,<URL>."
    echo -e "--cluster-name \t The name of the EKS Cluster. Needed when EKS is created with Terraform. Should match the name in Terraform."
    echo -e "--environment \t  The environment to use: qa or prod"
    echo -e "--terraform-plan \t  Run Terraform plan: true or false"
    echo -e "--terraform-apply \t Deploy terraform: true or false"
    echo -e "--terraform-destroy \t Destroy terraform stack: true or false"
    echo -e "--helm-charts \t Deploy helm charts: true or false"
    echo -e "--external-helm-charts \t specify external helm charts separated by a space. The arguments for each repo should be separated a comma.\n 
               Use the form: <NAME>,<REPO_KEY>,<REPO_URL>. To add additional args, please use the bitops-config.yaml file."
    echo -e "--ansible-playbooks \t Deploy Ansible playbooks: true or false"
    echo -e "--ansible-directory \t Directory containing your Ansible playbooks."
    echo -e "--use-config-file \t Use the configuration file: true or false"
}

function create_aws_profile() {
#!/usr/bin/env bash
echo "#!/usr/bin/env bash" > ~/.bashrc
echo "" >> ~/.bashrc
echo "PATH=/root/.local/bin:$PATH" >> ~/.bashrc
mkdir -p /root/.aws /root/.kube
cat <<EOF > /root/.aws/credentials
[default]
aws_access_key_id = "${AWS_ACCESS_KEY_ID}"
aws_secret_access_key = "${AWS_SECRET_ACCESS_KEY}"
EOF

cat <<EOF > /root/.aws/config
[default]
region = "$AWS_DEFAULT_REGION"
output = json
EOF
echo "#kubeconfig" > "$TEMPDIR"/.kube/config 
get_context
}

function create_config_map() {
    curl -o aws-auth-cm.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml
    TMP_WORKER_ROLE=$(terraform output | grep role | awk -F\rolearn: {'print $2'} | sed 's/^ //')
    AWS_ROLE_PREFIX=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $1'})
    ROLE_NAME=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $2'})
    WORKER_ROLE=$AWS_ROLE_PREFIX'\/'$ROLE_NAME
    cat aws-auth-cm.yaml   | sed 's/\<ARN of instance role (not instance profile)\>/'"$WORKER_ROLE"'/'g > aws-auth-cm.yaml-tmp
    mv aws-auth-cm.yaml-tmp aws-auth-cm.yaml
    kubectl apply -f aws-auth-cm.yaml
}

function get_context() {
    if [ -z "$KUBECONFIG_BASE64" ]
    then 
       echo "Unable to find KUBECONFIG_BASE64. Attempting to retrieve from Terraform..."
       if [ -z "$TERRAFORM_DIRECTORY" ]
       then
            echo "Error: Unable to extract kubeconfig from Terraform. Exiting..."
            return 1
        else
            terraform_plan
            if [ "$APPLY" == "true" ] && [ -n "$CLUSTER_NAME" ]
            then
                terraform_apply 
                TERRAFORM_APPLIED=1
                mkdir -p "$TEMPDIR"/.kube
                touch "$TEMPDIR"/.kube/config
                /root/.local/bin/aws sts get-caller-identity
                /root/.local/bin/aws eks update-kubeconfig --name "$CLUSTER_NAME"
                create_config_map
            else
                echo "Error: CLUSTER_NAME is empty or TERRAFORM_APPLY not set to true"
                usage
                return 1
            fi           
        fi    
    else
        #create config file
        echo "Creating kubeconfig file"
        mkdir -p "$TMPDIR"/.kube
        echo "${KUBECONFIG_BASE64}" | base64 -d > config
        mv config "$TEMPDIR"/.kube/config
        echo "Getting Kube Context"
        CONTEXT=$(grep name "$TEMPDIR"/.kube/config | head -1 | awk {'print $2'})

    fi
}

function helm_deploy_external_charts() {
    echo "Installing external helm charts"
    echo "REPOS: $CURRENT_ENVIRONMENT $EXTERNAL_HELM_CHARTS"

    for chart in "$EXTERNAL_HELM_CHARTS"
    do
      echo "Processing Charts: $chart"
      CHART_NAME=$(echo $chart | awk -F\, {'print $1'})
      REPO_KEY=$(echo $chart | awk -F\, {'print $2'})
      URL=$(echo $chart | awk -F\, {'print $3'})
      helm repo add $CHART_NAME $URL
      helm repo update
      helm upgrade --install "$CHART_NAME $CHART_NAME/$REPO_KEY"
    done
}

function helm_deploy_custom_charts() {
    echo "Installing charts..."
    path=""

    if [ -z "$HELM_CHARTS_DIRECTORY" ]
    then 
        echo "Helm directory not set. Using default directory."
        path=$ENVROOT/$CURRENT_ENVIRONMENT/helm
    else
        echo "Using provided Helm directory: $HELM_CHARTS_DIRECTORY"
        cp -rf "$HELM_CHARTS_DIRECTORY $ENVROOT/"
        path="$ENVROOT/$HELM_CHARTS_DIRECTORY/$CURRENT_ENVIRONMENT/helm"
    fi

    cd $path
    for subDir in `ls`
    do
            # initialize values files
            VALUES_FILE_PATH="./$subDir/values.yaml"
            VALUES_SECRETS_FILE_PATH="./$subDir/values-secrets.yaml"
            VALUES_VERSIONS_FILE_PATH="./$subDir/values-versions.yaml"
            DEFAULT_VALUES_FILE_PATH="$ENVROOT/default/helm/$subDir/values.yaml"
            ADDITIONAL_VALUES_FILES_PATH="$ENVROOT/default/helm/$subDir/values-files"
            echo "Updating dependencies in "$(pwd)"/"$subDir" ..."
            rm -rf "$subDir/charts"
            helm dep up "$(pwd)"/"$subDir"

            # initialize values command
            MAIN_VALUES_FILES_COMMAND=""
            for values_file in $VALUES_FILE_PATH $VALUES_SECRETS_FILE_PATH $VALUES_VERSIONS_FILE_PATH $DEFAULT_VALUES_FILE_PATH
            do
                if [ -e "$values_file" ];
                then
                    MAIN_VALUES_FILES_COMMAND="$MAIN_VALUES_FILES_COMMAND -f $values_file "
                else
                    echo "echo values file not found."
                fi
            done

            VALUES_FILES_COMMAND=""
            if [ -d "$ADDITIONAL_VALUES_FILES_PATH" ]; then
                echo "Additional values directory exists."
                for values_file in `ls "$ADDITIONAL_VALUES_FILES_PATH"`
                do
                    echo "processing values-file: $values_file"
                    VALUES_FILES_COMMAND="$VALUES_FILES_COMMAND -f $values_file "
                done
            else 
                echo "No values file directory. Skipping..."
            fi

            echo "Setting Helm release and chart variables."
            HELM_RELEASE_NAME="$subDir"
            CHART="$subDir"
            NAMESPACE=$(shyaml get-value namespace < $ENVROOT/$CURRENT_ENVIRONMENT/helm/$subDir/bitops.config.yaml | sed 's/^ //' | sed 's/\s$//')
            CHECK_NS=$(kubectl get namespaces --kubeconfig $KUBE_CONFIG_FILE | grep "$NAMESPACE" | awk {'print $1'} | grep ^"$NAMESPACE"$)
            # Check if namespace exists and create it if it doesn't.
            echo "Checking NAMESPACE: $NAMESPACE:"
            echo "Checking NS in System: $CHECK_NS:"
            if [ -n "$CHECK_NS" ];
            then
                echo "The namespace $NAMESPACE exists. Skipping creation..."
            else
                echo "The namespace $NAMESPACE does not exists. Creating..."
                kubectl --kubeconfig $KUBE_CONFIG_FILE create namespace $NAMESPACE
            fi
            pwd
            ls -ltr
            echo "Main Values Files: $MAIN_VALUES_FILES_COMMAND"
            echo "Command: helm upgrade $HELM_RELEASE_NAME $CHART --install --timeout=500s --cleanup-on-fail --kubeconfig=$KUBE_CONFIG_FILE --namespace=$NAMESPACE --kube-context=$CONTEXT -f $DEFAULT_VALUES_FILE_PATH -f $VALUES_FILE_PATH -f $VALUES_VERSIONS_PATH -f $VALUES_SECRETS_FILE_PATH $VALUES_FILES_COMMAND --dry-run"
            helm upgrade $HELM_RELEASE_NAME ./$CHART --install --timeout=600s \
            --cleanup-on-fail \
            --atomic \
            --kubeconfig="$KUBE_CONFIG_FILE" \
            --debug \
            --dry-run \
            --namespace="$NAMESPACE" \
            $MAIN_VALUES_FILES_COMMAND \
            $VALUES_FILES_COMMAND

            helm upgrade $HELM_RELEASE_NAME ./$CHART --install --timeout=600s \
            --cleanup-on-fail \
            --atomic \
            --kubeconfig="$KUBE_CONFIG_FILE" \
            --namespace="$NAMESPACE" \
            $MAIN_VALUES_FILES_COMMAND \
            $VALUES_FILES_COMMAND
    done

}

function install_from_s3() {
    helm plugin install https://github.com/hypnoglow/helm-s3.git
    CHART_NAME=$(echo $HELM_CHARTS_S3 | awk -F\, {'print $1'})
    S3_BUCKET=$(echo $HELM_CHARTS_S3 | awk -F\, {'print $2'})
    helm repo add $CHART_NAME $S3_BUCKET
    helm repo list
}

function clean_workspace() {
    echo "Running cleanup..."
    rm -rf "$TEMPDIR"
}

# extract options and their arguments into variables.
while true; do
    case "$1" in
        -h | --help)
            usage
            exit 1
            ;;
        --kubeconfig-base64)
            KUBECONFIG_BASE64="$2";
            shift 2
            ;;
        --terraform-directory)
            TERRAFORM_DIRECTORY="$2";
            shift 2
            ;;
        --terraform-plan)
            PLAN="$2";
            shift 2
            ;;
        --terraform-apply)
            APPLY="$2";
            shift 2
            ;;
        --terraform-destroy)
            DESTROY="$2";
            shift 2
            ;;
        --environment)
            CURRENT_ENVIRONMENT="$2";
            shift 2
            ;;
        --cluster-name)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        --helm-charts)
            HELM_CHARTS="$2";
            shift 2
            ;;
        --helm-charts-directory)
            HELM_CHARTS_DIRECTORY="$2";
            shift 2
            ;;
        --helm-s3-repo)
            HELM_CHARTS_S3="$2";
            shift 2
            ;;
        --external-helm-charts)
            EXTERNAL_HELM_CHARTS="$2";
            shift 2
            ;;          
        --ansible-playbooks)
            ANSIBLE_PLAYBOOKS="$2";
            shift 2
            ;;
        --ansible-directory)
            ANSIBLE_DIRECTORY="$2";
            shift 2
            ;;
        --install-default-charts)
            DEFAULT_CHARTS="$2";
            shift 2
            ;;
        --use-config-file)
            USE_CONFIG_FILE="$2"
            shift 2
            ;;
        --)
            break
            ;;
        *)
            break
            ;;
    esac
done
 
echo "Running deployments"

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]
then
    echo "Your AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY is not set."
    return 1
else
    echo "Creating AWS Profile"
    create_aws_profile
fi

if [ -z "$USE_CONFIG_FILE" ]
then
    echo "USE_CONFIG_FILE not set."
else
    echo "Reading config file."
        # Read config files
        ANSIBLE_PLAYBOOKS=$(scripts/deploy/config_ansible.sh)
        CLOUD_PLATFORM=$(scripts/deploy/config_cloud.sh)
        EXTERNAL_HELM_CHARTS=$(scripts/deploy/config_external_helm_charts.sh)
        HELM_CHARTS=$(scripts/deploy/config_helm.sh)
        # HELM_CHARTS_S3=$(scripts/deploy/config_helm_s3.sh)
        # APPLY=$(scripts/deploy/config_terraform_apply.sh)
        # PLAN=$(scripts/deploy/config_terraform_plan.sh)
        # DESTROY=$(scripts/deploy/config_terraform_destroy.sh)
        # HELM_CHARTS_DIRECTORY=$(scripts/deploy/config_helm_directory.sh)
        # ANSIBLE_DIRECTORY=$(scripts/deploy/config_ansible_directory.sh)
fi

if [[ ${PLAN} == "true" ]];then
    scripts/deploy/terraform_apply.sh
fi

if [[ ${APPLY} == "true" ]];then
    echo "Running Terraform Apply"
    scripts/deploy/terraform_apply.sh
fi

if [[ ${DESTROY} == "true" ]];then
    echo "Destroying EKS Cluster"
    scripts/deploy/terraform_destroy.sh
fi

if [[ ${HELM_CHARTS} == "true" ]];then
    echo "Installing Helm Charts"
    helm_deploy_custom_charts
fi 

if [ -z "$EXTERNAL_HELM_CHARTS" ]
then 
    echo "EXTERNAL_HELM_CHARTS directory not set."
else
    echo "Running External Helm Charts."
    helm_deploy_external_charts
fi

if [[ ${ANSIBLE_PLAYBOOKS} == "true" ]];then
    echo "Running Ansible Playbooks"
    scripts/deploy/ansible_install_playbooks.sh
fi 

if [ -z "$HELM_CHARTS_S3" ]
then
    echo "HELM_CHARTS_S3 not set."
else
    echo "Adding S3 Helm Repo."
    install_from_s3
fi

# Cleanup Workspace
clean_workspace