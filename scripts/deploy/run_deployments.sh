#!/usr/bin/env bash

set -e 

export PATH=/root/.local/bin:$PATH
export TERRAFORM_APPLIED=0
export DEPLOYMENT_DIR=""

if [ -e /opt/our_deployment ];
then
    DEPLOYMENT_DIR=/opt/our_deployment
else
    DEPLOYMENT_DIR=/opt/deploy/
fi

# Read the options from cli input
OPTIONS=`getopt -o h --longoptions help,kubeconfig_base64:,terraform-directory:,environment:,terraform-plan:,terraform-apply:,terraform-destroy:,helm-charts:,ansible-directory:,ansible-playbooks:,external-helm-charts:,helm-charts-directory: -n $0 -- "$@"`
eval set -- "${OPTIONS}"


echo "options: ${OPTIONS}"
if [[ $# == 1 ]] ; then echo "No input provided! type ($0 --help) to see usage help" >&2 ; exit 1 ; fi

function usage() {
    echo "$0 <usage>"
    echo " "
    echo "options:"
    echo -e "--help \t Show options for this script"
    echo -e "--kubeconfig_base64 \t Pass in the environment variable containing the base64 contents of your kube config."
    echo -e "--terraform-directory \t The directory for the terraform deployment"
    echo -e "--helm-charts-directory \t The directory containing your helm charts. Use only if charts are in alternate location."
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
> /root/.kube/config 
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
    CONTEXT=$(grep name ~/.kube/config | head -1 | awk {'print $2'})
    if [ -z "$CONTEXT" ]
    then
        echo "Context not set"
    else
        kubectl config use-context $CONTEXT
        kubectl config current-context
        if [ "$?" -eq 0 ]
        then
           echo "Kubernetes context set."
           exit 0
        fi       
    fi

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
                mkdir -p ~/.kube
                touch ~/.kube/config
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
        mkdir -p ~/.kube
        echo ${KUBECONFIG_BASE64} | base64 -d > config
        mv config ~/.kube/config
        echo "Getting Kube Context"
        CONTEXT=$(grep name ~/.kube/config | head -1 | awk {'print $2'})
        kubectl config use-context $CONTEXT
        kubectl config current-context
        echo "Testing config:"
        kubectl --v=4 get nodes 
        kubectl --v=4 get pods --all-namespaces
        if [ "$?" -eq 0 ]
        then
           echo "Kubernetes context is configured."
        else
           echo "Context not set, attempting to set context explicitly."
           kubectl config set-context $CONTEXT
        fi

    fi
}

function terraform_plan() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd $CURRENT_ENVIRONMENT/$DEPLOYMENT_DIR
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    else
       #Run Terraform Plan
       cd $CURRENT_ENVIRONMENT/$TERRAFORM_DIRECTORY
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    fi
}

function terraform_apply() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd $CURRENT_ENVIRONMENT/$DEPLOYMENT_DIR
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    else
       #launch terraform to create EKS cluster
       cd $CURRENT_ENVIRONMENT/$TERRAFORM_DIRECTORY
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
       /usr/local/bin/terraform apply -auto-approve
    fi  
}

function terraform_destroy() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set. Using default directory."
        cd $CURRENT_ENVIRONMENT/$DEPLOYMENT_DIR
        /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    else
       #Destroying EKS cluster
       cd $CURRENT_ENVIRONMENT/$TERRAFORM_DIRECTORY
       /usr/local/bin/terraform init
       /usr/local/bin/terraform destroy -auto-approve
    fi     
}

function helm_deploy_external_charts() {
    echo "Installing external helm charts"
    echo "REPOS: $CURRENT_ENVIRONMENT $EXTERNAL_HELM_CHARTS"

    for chart in $EXTERNAL_HELM_CHARTS
    do
      echo "Processing Charts: $chart"
      CHART_NAME=$(echo $chart | awk -F\, {'print $1'})
      REPO_KEY=$(echo $chart | awk -F\, {'print $2'})
      URL=$(echo $chart | awk -F\, {'print $3'})
      echo "NAME: $CHART_NAME, CHART_NAME: $REPO_KEY, URL: $URL"
      echo "helm repo command: helm repo add $NAME $URL"
      echo "helm install command: helm upgrade --install $CHART_NAME/$REPO_KEY"
      helm repo add $CHART_NAME $URL
      helm repo update
      helm upgrade --install $CHART_NAME $CHART_NAME/$REPO_KEY
    done
}

function helm_deploy_charts() {
    echo "Installing helm charts"
    path=""

    if [ -z "$HELM_CHARTS_DIRECTORY" ]
    then 
        echo "Helm directory not set. Using default directory."
        path=$DEPLOYMENT_DIR/$CURRENT_ENVIRONMENT/
    else
        echo "Using provided Helm directory: $HELM_CHARTS_DIRECTORY"
        path=$HELM_CHARTS_DIRECTORY/$CURRENT_ENVIRONMENT/
    fi
    
    cd $path/helm
    chart_name=$(grep name Chart.yaml | head -1 | awk -F\: {'print $2'} | sed 's/^ //')
    if [ -e requirements.yaml ]; then
        helm dependency update
        cd ../
        helm install $chart_name ./helm/
    else
        echo "Can't find requirement.yaml"
        return 1
    fi
}

function install_grafana() {
    helm repo add loki https://grafana.github.io/loki/charts
    helm repo update
    helm install --name grafana stable/grafana --set=ingress.enabled=True,ingress.hosts={grafana} --set rbac.create=true
}

function run_ansible_playbooks() {
    path=""

    if [ -z "$ANSIBLE_DIRECTORY" ]
    then 
        echo "Helm directory not set. Using default directory."
        path=$DEPLOYMENT_DIR/$CURRENT_ENVIRONMENT/ansible
    else
        echo "Using provided Ansible directory: $ANSIBLE_DIRECTORY"
        path=$CURRENT_ENVIRONMENT/$ANSIBLE_DIRECTORY/
    fi
    /root/.local/bin/ansible-playbook $path
}


# extract options and their arguments into variables.
while true; do
    case "$1" in
        -h | --help)
            usage
            exit 1
            ;;
        --kubeconfig_base64)
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
            APPLY="$2";
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
        --)
            break
            ;;
        *)
            break
            ;;
    esac
done
 
echo "Running deployments"
echo "${PLAN} ${TERRAFORM_DIRECTORY} ${HELM_CHARTS} ${CURRENT_ENVIRONMENT}"

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]
then
    echo "Your AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY is not set."
    return 1
else
    echo "Creating AWS Profile"
    create_aws_profile
fi

if [[ ${PLAN} == "true" ]];then
    terraform_plan
fi

if [[ ${APPLY} == "true" ]];then
    echo "Running Terraform Apply"
    terraform_apply
fi

if [[ ${DESTROY} == "true" ]];then
    echo "Destroying EKS Cluster"
    terraform_destroy
fi

if [[ ${HELM_CHARTS} == "true" ]];then
    echo "Installing Helm Charts"
    helm_deploy_charts
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
    run_ansible_playbooks
fi 

