#!/usr/bin/env bash
set -x

python3 --version
find / -name pip3
pip3 install --upgrade --user 'awscli==1.17.7'

export TERRAFORM_VERSIONS=$(cat build.config.yaml | shyaml get-values terraform.versions)
export HELM_VERSION=$(cat build.config.yaml | shyaml get-value helm.version)
export KUBECTL_VERSION=$(cat build.config.yaml | shyaml get-value kubectl.version)
export CLOUD_PLATFORM=$(cat build.config.yaml | shyaml get-value cloud_platform.name)
export CI_PLATFORM=$(cat build.config.yaml | shyaml get-value ci_platform.name)
export AWS_REGION=$(cat build.config.yaml | shyaml get-value cloud_platform.region)
export CURRENT_ENVIRONMENT=$(cat build.config.yaml | shyaml get-value environment.default)


mkdir -p /opt/download
cd /opt/download

function install_terraform() {
    while IFS='' read -r version; do
        TERRAFORM_DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip"
        echo ${TERRAFORM_DOWNLOAD_URL}
        curl -LO ${TERRAFORM_DOWNLOAD_URL} && unzip terraform_${version}_linux_amd64.zip -d ./
        mv terraform /usr/local/bin/terraform-${version}
        chmod +x /usr/local/bin/terraform-${version}
    done <<< "$TERRAFORM_VERSIONS"
}


function install_aws_iam_authenticator() {
    curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
    mv aws-iam-authenticator /usr/local/bin/
    chmod u+x /usr/local/bin/helm /usr/local/bin/aws-iam-authenticator

}


function install_kubectl() {
    wget https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/kubectl
    chmod +x ./kubectl && mv kubectl /usr/local/bin/
}


function install_helm() {
    if [[ "$HELM_VERSION" == '3.2.0' ]]; then
        wget https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz
        tar -xzvf helm-v$HELM_VERSION-linux-amd64.tar.gz
        mv linux-amd64/helm /usr/local/bin/
    else
        wget https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz
        tar -xzvf helm-v$HELM_VERSION-linux-amd64.tar.gz
        mv linux-amd64/helm /usr/local/bin/
        bash -x scripts/helm/install_tiller.sh
    fi
}
function install_helm_s3() {
    helm plugin install https://github.com/hypnoglow/helm-s3.git
}

function install_ansible() {
    pip3 install --user ansible
}


function install_mysqlclient() {
    curl -LO https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb
    dpkg -i mysql-apt-config*
    apt-get update
    apt-get -y install mysql-client
}


function configure_cloud_platorm() {
    if [[ "$CLOUD_PLATORM" -eq "AWS" ]]
    then
    echo "Configuring AWS"
mkdir /root/.aws /root/spec
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

# Configure AWSpec
cat <<EOF > spec/secrets.yml
region: "$AWS_DEFAULT_REGION"
aws_access_key_id: "${AWS_ACCESS_KEY_ID}"
aws_secret_access_key: "${AWS_SECRET_ACCESS_KEY}"
EOF
    else
    # Configure GCE
    echo "Configuring GCE"

    fi
}

configure_cloud_platorm
install_terraform
install_aws_iam_authenticator
install_kubectl
install_helm
install_helm_s3
install_ansible
install_mysqlclient

# Cleanup
rm -rf /opt/download
