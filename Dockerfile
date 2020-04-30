FROM python:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y software-properties-common libsodium-dev \
    && apt-get install -y inetutils-ping vim wget unzip curl git jq awscli ruby-full \
    && rm -rf /var/lib/apt/lists/* \
    # && gem install travis --no-rdoc --no-ri \
    # && gem install rbnacl --no-rdoc --no-ri \
    # && gem install awspec --no-rdoc --no-ri  \
    # && gem install kitchen-terraform --version 5.3.0 --no-rdoc --no-ri \
    # && gem install kitchen-verifier-awspec --no-rdoc --no-ri \
    && mkdir -p /opt/bitops
WORKDIR /opt/bitops
COPY . .
COPY entrypoint.sh /opt/bitops/scripts/entrypoint.sh
RUN pip3 install -r requirements.txt
RUN bash -x scripts/setup/install_tools.sh
ENTRYPOINT [ "/opt/bitops/scripts/entrypoint.sh" ]