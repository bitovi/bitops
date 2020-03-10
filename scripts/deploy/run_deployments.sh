#!/usr/bin/env bash

set -e 

export PATH=/root/.local/bin:$PATH
# Read the options from cli input
OPTIONS=`getopt -o h --longoptions help,kubeconfig:,terraform-directory:,environment:,terraform-plan:,terraform-apply:,terraform-destroy:,helm-charts:,ansible-directory:,install-prometheus:,install-grafana:,install-loki:,install-default-charts:,domain-name:,namespace: -n $0 -- "$@"`
eval set -- "${OPTIONS}"


echo "options: ${OPTIONS}"
if [[ $# == 1 ]] ; then echo "No input provided! type ($0 --help) to see usage help" >&2 ; exit 1 ; fi

function usage() {
    echo "$0 <usage>"
    echo " "
    echo "options:"
    echo -e "--help \t Show options for this script"
    echo -e "--kubeconfig \t Pass in the environment variable containing the kubernetes config. If left empty, terraform will create a new kubernetes cluster."
    echo -e "--terraform-directory \t The directory for the terraform deployment"
    echo -e "--environment \t  The environment to use: qa or prod"
    echo -e "--terraform-plan \t  Run Terraform plan"
    echo -e "--terraform-apply \t Deploy terraform"
    echo -e "--terraform-destroy \t Destroy terraform stack"
    echo -e "--helm-charts \t The folder containing the helm charts"
    echo -e "--ansible-directory \t The directory containing your ansible playbooks"
    echo -e "--domain-name \t Set the domain name. Required for Prometheus and Grafana."
    echo -e "--namespace \t Set the namespace to be used by Prometheus and Grafana."
    echo -e "--install-default-charts \t Install Prometheus, Grafana and Loki on the cluster"
}

function get_context() {
    if [ -z "KUBECONFIG" ]
    then 
       #launch terraform to create EKS cluster
       cd /opt/deploy/terraform/
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
       #/usr/local/bin/terraform apply -auto-approve
       #mkdir -p ~/.kube
       #/root/.local/bin/aws sts get-caller-identity
       #/root/.local/bin/aws eks update-kubeconfig --name bitops 
    else
       #create config file
       mkdir -p ~/.kube
cat << 'EOF' >> ~/.kube/config
# kubeconfig
$KUBECONFIG2
EOF

       kubectl config get-contexts 
    fi
}

function terraform_plan() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set."
        return 1
    else
       #launch terraform to create EKS cluster
       cd $TERRAFORM_DIRECTORY/$CURRENT_ENVIRONMENT
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
    fi
}

function terraform_apply() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set."
        return 1
    else
       #launch terraform to create EKS cluster
       cd $TERRAFORM_DIRECTORY/$CURRENT_ENVIRONMENT
       /usr/local/bin/terraform init && /usr/local/bin/terraform plan
       /usr/local/bin/terraform apply -auto-approve
    fi  
}

function terraform_destroy() {
    if [ -z "$TERRAFORM_DIRECTORY" ]
    then 
        echo "Terraform directory not set."
        return 1
    else
       #launch terraform to create EKS cluster
       cd $TERRAFORM_DIRECTORY/$CURRENT_ENVIRONMENT
       /usr/local/bin/terraform init
       /usr/local/bin/terraform destroy -auto-approve
    fi     
}

function helm_deploy_default_charts() {
    get_context
    install_grafana
    install_prometheus
    install_loki
}

function helm_deploy_custom_charts() {
    echo "Installing charts in $HELM_CHARTS"

    # Get Kubernetes context
    get_context

    path=$HELM_CHARTS
    cd $path
    if [ -e requirements.yaml ]; then
        for subDir in $(awk -F'repository: file://' '{print $2}' requirements.yaml)
        do
            echo "Updating dependencies in "$(pwd)"/"$subDir" ..."
            rm -rf "$(pwd)"/"$subDir"/charts
            helm dep up "$(pwd)"/"$subDir"
            echo
        done
        echo "Updating dependencies in "$(pwd)" ..."
        rm -rf "$(pwd)"/charts
        helm dep up "$(pwd)"
        echo
    else
        echo "Can't find requirement.yaml in $HELM_CHARTS/requirement.yaml."
        return 1
    fi

}

function install_grafana() {
    get_context
    helm repo add loki https://grafana.github.io/loki/charts
    helm repo update
    helm install --name grafana stable/grafana --set=ingress.enabled=True,ingress.hosts={grafana.$DOMAIN_NAME} --namespace $NAMESPACE --set rbac.create=true
}

function install_prometheus() {
    get_context
    mkdir -p /opt/prometheus
    cd /opt/prometheus
    git clone https://github.com/helm/charts.git
    cd charts/stable/prometheus
    helm install --name=prometheus . --namespace $NAMESPACE --set rbac.create=true
}

function install_loki() {
    get_context
    if [ -z "$NAMESPACE" ]
    then
        echo "No namespace set. Default will be used."
        helm repo add loki https://grafana.github.io/loki/charts
        helm repo update
        helm upgrade --install loki loki/loki
    else
        helm repo add loki https://grafana.github.io/loki/charts
        helm repo update
        helm upgrade --install loki loki/loki --namespace $NAMESPACE 
    fi

}

function run_ansible_playbooks() {
    if [ -z "$ANSIBLE_PLAYBOOKS" ]
    then
        echo "Ansible Playbook is empty"
        return 1
    else
        /root/.local/bin/ansible-playbook $ANSIBLE_PLAYBOOKS
    fi
}


# extract options and their arguments into variables.
while true; do
    case "$1" in
        -h | --help)
            usage
            exit 1
            ;;
        --kubeconfig)
            KUBECONFIG="$2";
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
        --helm-charts)
            HELM_CHARTS="$2";
            shift 2
            ;;
        --ansible-directory)
            ANSIBLE_PLAYBOOKS="$2";
            shift 2
            ;;
        --install-prometheus)
            PROMETHEUS="$2";
            shift 2
            ;;
        --install-grafana)
            GRAFANA="$2";
            shift 2
            ;;
        --install-loki)
            LOKI="$2";
            shift 2
            ;;
        --install-default-charts)
            DEFAULT_CHARTS="$2";
            shift 2
            ;;
        --domain-name)
            DOMAIN_NAME="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
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
echo "${PLAN} ${DOMAIN_NAME} ${TERRAFORM_DIRECTORY} ${HELM_CHARTS} ${CURRENT_ENVIRONMENT}"

if [[ ${PLAN} == "true" ]];then
    terraform_plan
fi

if [[ ${APPLY} == "true" ]];then
    terraform_apply
fi

if [[ ${DESTROY} == "true" ]];then
    terraform_destroy
fi

if [ -z "$HELM_CHARTS" ]
then 
    echo "Helm directory not set."
else
    echo "Installing Helm Charts"
    helm_deploy_custom_charts
fi 

if [ -z "$ANSIBLE_PLAYBOOKS" ]
then 
    echo "Ansible Playbooks directory not set."
else
    echo "Running Ansible Playbooks"
    run_ansible_playbooks
fi 