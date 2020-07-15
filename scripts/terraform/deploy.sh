#!/usr/bin/env bash

set -ex 

# terraform vars
export CREATE_KUBECONFIG_BASE64="false"
export TERRAFORM_APPLIED="false"
CREATE_CLUSTER=false

printf "Deploying terraform... ${NC}"
if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    printf "${ERROR}Your AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY is not set."
    return 1
fi

if [ -n "$CLUSTER_NAME" ]; then
    echo "Using $CLUSTER_NAME cluster..."
else
    CLUSTER_NAME=$(shyaml get-value cluster < "$TEMPDIR/$ENVIRONMENT"/terraform/bitops.config.yaml || true)
    CLUSTER_NAME=$(echo $CLUSTER_NAME | sed 's/true//g')
    if [ -z "$CLUSTER_NAME" ]; then
        printf "${ERROR} Please set the CLUSTER_NAME environment variable. If you do not have a cluster set the TERRAFORM_APPLY to true .${NC} "
        return 1 
    fi
fi

# TODO: How about we just move all this 'make a kubeconfig' stuff into the terraform apply
if [ ! -f "$KUBE_CONFIG_FILE" ]; then 
    echo "${WARN}KUBE_CONFIG_FILE is empty${NC}"
    if [ "$TERRAFORM_APPLY" == "true" ]; then
      echo "Unable to find kubeconfig ($KUBE_CONFIG_FILE). Attempting to retrieve KUBECONFIG from Terraform..."
      printf "${WARN}This will create an EKS Cluster in AWS. Charges may apply.${NC}"

      CREATE_KUBECONFIG_BASE64=true
      bash $SCRIPTS_DIR/terraform/terraform_apply.sh
      export KUBECONFIG_BASE64=$(cat "$KUBE_CONFIG_FILE" | base64)
    fi

    # TODO: what are these alternate commands used for?
    # if [ "${TERRAFORM_PLAN_ALTERNATE_COMMAND}" == "true" ]; then
    #   printf "${WARN}Running Alternate Terraform command.${NC}"
    #   bash $SCRIPTS_DIR/terraform/terraform_plan.sh
    # fi

    # if [ "${TERRAFORM_APPLY_ALTERNATE_COMMAND}" == "true" ]; then
    #   printf "${WARN}Running Alternate Terraform command.${NC}"
    #   bash $SCRIPTS_DIR/terraform/terraform_apply.sh
    # fi

    if [ -z "$TERRAFORM_APPLY" ]; then
      printf "${WARN}TERRAFORM_APPLY and KUBECONFIG is empty...
      Either supply KUBECONFIG_BASE64 or set TERRAFORM_APPLY to true...${NC}"
    fi

fi


if  [ ! -f "$KUBE_CONFIG_FILE" ] && [[ ${TERRAFORM_APPLY} == "false" ]] && [[ ${TEST} == "false" ]]; then
    printf "${ERROR} You did not supply a kubeconfig and you have chosen not to create a cluster.\n
    To create a cluster, set the environment variable TERRAFORM_APPLY to true.${NC} "
    return 1
fi



if [[ "${TERRAFORM_PLAN}" == "true" ]];then
    echo "Running Terraform Plan"
    bash $SCRIPTS_DIR/terraform/terraform_plan.sh
fi

if [[ "${TERRAFORM_APPLY}" == "true" ]]; then
  bash $SCRIPTS_DIR/terraform/terraform_apply.sh
fi

if [[ "${TERRAFORM_DESTROY}" == "true" ]];then
    echo "Destroying Cluster"
    bash $SCRIPTS_DIR/terraform/terraform_destroy.sh
fi






# TODO: this was copied from an old file. Do we need it?
# function create_config_map() {
#     echo "Creating config map."
#     curl -o aws-auth-cm.yaml https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml
#     TMP_WORKER_ROLE=$(shyaml get-value role < $TEMPDIR/opscruise-test/terraform/bitops.config.yaml)
#     AWS_ROLE_PREFIX=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $1'})
#     ROLE_NAME=$(echo $TMP_WORKER_ROLE | awk -F\/ {'print $2'})
#     WORKER_ROLE=$AWS_ROLE_PREFIX'\/'$ROLE_NAME
#     cat aws-auth-cm.yaml | sed 's/ARN of instance role (not instance profile)//g' | sed 's/[<]/'"$ROLE"'/g' | sed 's/[>]//g' > aws-auth-cm.yaml-tmp
#     rm -rf aws-auth-cm.yaml
#     mv aws-auth-cm.yaml-tmp aws-auth-cm.yaml
#     kubectl apply --kubeconfig="$KUBE_CONFIG_FILE" -f aws-auth-cm.yaml
# }





