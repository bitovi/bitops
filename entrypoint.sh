#!/usr/bin/env bash
set -xe

export PATH=/root/.local/bin:$PATH
export TEMPDIR="/tmp/bitops_deployment"
export SECRETS_MGR=""
export IMG_REPO=""
export ENVROOT="$TEMPDIR/$ENVIRONMENT"
export KUBE_CONFIG_FILE="$TEMPDIR/.kube/config"
export HELM_RELEASE_NAME=""
export HELM_DEBUG_COMMAND=""
export BITOPS_DIR="/opt/bitops"
export SCRIPTS_DIR="$BITOPS_DIR/scripts"
export ERROR='\033[0;31m'
export SUCCESS='\033[0;32m'
export NC='\033[0m'
export CLUSTER_NAME=""
export CREATE_KUBECONFIG_BASE64="false"

# ops repo paths
ROOT_DIR="/opt/bitops_deployment"
ENVROOT="$ROOT_DIR/$ENVIRONMENT"

CREATE_CLUSTER=false

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  printf "${ERROR}environment variable (AWS_ACCESS_KEY_ID) not set ${NC}"
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  printf "${ERROR}environment variable (AWS_SECRET_ACCESS_KEY) not set ${NC}"
  exit 1
fi
if [ -z "$AWS_DEFAULT_REGION" ]; then
  printf "${ERROR}environment variable (AWS_DEFAULT_REGION) not set ${NC}"
  exit 1
fi
if [ -z "$CLUSTER_NAME" ]; then
  echo "environment variable (CLUSTER_NAME) not set "
  CREATE_CLUSTER=true
fi
if [ -z "$ENVIRONMENT" ]; then
  printf "${ERROR}environment variable (ENVIRONMENT) not set ${NC}"
  exit 1
fi
if [ -z "$DEBUG" ]; then
  echo "environment variable (DEBUG) not set"
  export DEBUG=0
fi
if [ -z "$KUBECONFIG_BASE64" ]; then
  echo "environment variable (KUBECONFIG_BASE64) not set"
fi
if [ -z "$NAMESPACE" ]; then
  echo "environment variable (NAMESPACE) not set"
  export NAMESPACE="default"
fi
if [ -z "$TIMEOUT" ]; then
  echo "environment variable (TIMEOUT) not set"
  export TIMEOUT="500s"
fi

rm -rf /tmp/bitops_deployment

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
export KUBE_CONFIG_FILE="$TEMPDIR"/.kube/config
get_context
}

function create_config_map() {
    echo "Creating config map."
    curl -o aws-auth-cm.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml
    TMP_WORKER_ROLE=$(shyaml get-value role < $TEMPDIR/opscruise-test/terraform/bitops.config.yaml)
    AWS_ROLE_PREFIX=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $1'})
    ROLE_NAME=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $2'})
    WORKER_ROLE=$AWS_ROLE_PREFIX'\/'$ROLE_NAME
    cat aws-auth-cm.yaml | sed 's/ARN of instance role (not instance profile)//g' | sed 's/[<]/'"$ROLE"'/g' | sed 's/[>]//g' > aws-auth-cm.yaml-tmp
    rm -rf aws-auth-cm.yaml
    mv aws-auth-cm.yaml-tmp aws-auth-cm.yaml
    kubectl apply --kubeconfig="$KUBE_CONFIG_FILE" -f aws-auth-cm.yaml
}

function get_context() {
    if [ -n "$CLUSTER_NAME" ]; then
        echo "Using $CLUSTER_NAME cluster..."
    else
        CLUSTER_NAME=$(shyaml get-value cluster < "$TEMPDIR/$ENVIRONMENT"/terraform/bitops.config.yaml || true)
        CLUSTER_NAME=$(echo $CLUSTER_NAME | sed 's/true//g')
        if [ -z "$CLUSTER_NAME" ]; then
            printf "${ERROR} If you already have a cluster. please set the CLUSTER_NAME environment variable.${NC} "
            return 1 
        fi
    fi
    if [ -z "$KUBECONFIG_BASE64" && -z "$TF_APPLY" ] || [ -z "$KUBECONFIG_BASE64" && "$TF_APPLY" == "true" ]
    then 
        echo "Unable to find KUBECONFIG_BASE64. Attempting to retrieve KUBECONFIG from Terraform..."
        CREATE_KUBECONFIG_BASE64=true
        bash $SCRIPTS_DIR/terraform/terraform_apply.sh
        export KUBECONFIG_BASE64=$(cat "$TEMPDIR"/.kube/config | base64)
    elif [ -z "$KUBECONFIG_BASE64" && "$TF_APPLY" == "false" ]; then
        printf "${ERROR} You did not supply KUBECONFIG_BASE64 and you have chosen not to create a cluster.\n To create a cluster, set the environment variable TF_APPLY to true.${NC} "
        return 1
    elif [ -n "$KUBECONFIG_BASE64" ]; then
        #create config file
        echo "Creating kubeconfig file"
        mkdir -p "$TMPDIR"/.kube
        echo "${KUBECONFIG_BASE64}" | base64 -d > config
        mv config "$TEMPDIR"/.kube/config
        export KUBE_CONFIG_FILE="$TEMPDIR"/.kube/config
    else
        printf "${ERROR} You did not supply KUBECONFIG_BASE64 and you have chosen not to create a cluster.\n
        To create a cluster, set the environment variable TF_APPLY to true.${NC} "
        return 1
    fi

}

function clean_workspace() {
    echo "Running cleanup..."
    rm -rf "$TEMPDIR"
}

echo "Running deployments"

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]
then
    printf "${ERROR}Your AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY is not set."
    return 1
else
    echo "Creating AWS Profile"
    create_aws_profile
fi

if [[ ${TF_PLAN} == "true" ]];then
    echo "Running Terraform Plan"
    bash $SCRIPTS_DIR/terraform/terraform_plan.sh
fi

if [[ ${TF_APPLY} == "true" ]];then
    echo "Running Terraform Apply"
    bash $SCRIPTS_DIR/terraform/terraform_apply.sh
fi

if [[ ${TF_DESTROY} == "true" ]];then
    echo "Destroying Cluster"
    bash $SCRIPTS_DIR/terraform/terraform_destroy.sh
fi

if [[ ${HELM_CHARTS} == "true" ]];then
    echo "Installing Helm Charts"
    /bin/bash $SCRIPTS_DIR/helm/helm_install_charts.sh
fi 

if [ -z "$EXTERNAL_HELM_CHARTS" ]
then 
    echo "EXTERNAL_HELM_CHARTS directory not set."
else
    echo "Running External Helm Charts."
    bash -x $SCRIPTS_DIR/helm/helm_install_external_charts.sh
fi

if [ -z "$HELM_CHARTS_S3" ]
then
    echo "HELM_CHARTS_S3 not set."
else
    echo "Adding S3 Helm Repo."
    bash -x $SCRIPTS_DIR/helm/helm_install_charts_from_s3.sh 
fi

if [[ ${ANSIBLE_PLAYBOOKS} == "true" ]];then
    echo "Running Ansible Playbooks"
    bash -x $SCRIPTS_DIR/ansible/ansible_install_playbooks.sh
fi 

# Cleanup Workspace
clean_workspace
printf "${SUCCESS}BitOps Completed Successfully.${NC}"
