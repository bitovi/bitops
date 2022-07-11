## Using alpine fails on awscli install
FROM python:3.8.6-alpine
ENV DEBIAN_FRONTEND=noninteractive
RUN apk add --no-cache bash
RUN apk update

RUN apk add \
    libsodium-dev \
    wget \
    unzip \
    git \
    jq \
    curl
    
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
COPY scripts/ ./scripts
COPY bitops.config.yaml .
COPY bitops.schema.yaml .
COPY requirements.txt .

RUN pip3 install -r requirements.txt
RUN python3 scripts/plugins.py install

ONBUILD WORKDIR /opt/bitops
# ONBUILD COPY scripts/ ./scripts has proven quite useful for rapid testing. Please keep in while testing. 
ONBUILD COPY scripts/ ./scripts
ONBUILD COPY bitops.config.yaml .
ONBUILD COPY bitops.schema.yaml .
ONBUILD RUN python3 scripts/plugins.py install

ENTRYPOINT ["python3", "/opt/bitops/scripts/plugins.py", "deploy"]