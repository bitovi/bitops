## Using alpine fails on awscli install
FROM python:3.8.6-alpine
ENV DEBIAN_FRONTEND=noninteractive
RUN apk add --no-cache bash
RUN apk update

RUN apk add \
    ansible \
    libsodium-dev \
    wget \
    unzip \
    git \
    jq \
    curl \
    rsync \
    openssh
    
# install glibc compatibility for alpine
ENV GLIBC_VER=2.31-r0
RUN apk --no-cache add \
        binutils \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip -q awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
        binutils \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*
    

RUN mkdir -p /opt/bitops

WORKDIR /opt/bitops
COPY . .

RUN pip3 install -r requirements.txt
RUN bash -x scripts/setup/install_tools.sh

ENTRYPOINT [ "/opt/bitops/scripts/deploy.sh" ]
