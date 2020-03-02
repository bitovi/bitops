FROM python:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y software-properties-common \
    # && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get install -y inetutils-ping vim wget unzip curl git jq awscli ruby-full \
    && rm -rf /var/lib/apt/lists/* \
    && gem install travis \
    && mkdir -p /opt/deploy
#RUN gem install travis
#RUN 
WORKDIR /opt/deploy
COPY . .
COPY entrypoint.sh /opt/deploy/
RUN pip3 install -r requirements.txt
RUN bash -x scripts/setup/install_tools.sh

#CMD ["ping", "8.8.8.8"]
ENTRYPOINT [ "/opt/deploy/entrypoint.sh" ]