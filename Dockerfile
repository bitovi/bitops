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
    curl \
    rsync \
    openssh
    
# install glibc compatibility for alpine
ENV GLIBC_VER=2.31-r0
RUN mkdir -p /opt/bitops

WORKDIR /opt/bitops
COPY scripts/ ./scripts
COPY bitops.config.yaml .
COPY bitops.schema.yaml .
COPY requirements.txt .

RUN pip3 install -r requirements.txt

ONBUILD WORKDIR /opt/bitops
ONBUILD COPY bitops.config.yaml .
ONBUILD RUN python3 scripts/main.py install

ENTRYPOINT ["python3", "/opt/bitops/scripts/main.py", "deploy"]
