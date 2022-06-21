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