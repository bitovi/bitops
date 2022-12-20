## Using alpine fails on awscli install
FROM python:3.8.6-alpine
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
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


# temporarily set the working dir to `/opt/bitops-local-plugins`
#    to copy local plugins from a custom bitops repo into the container
#    at build time to allow installing dependencies
ONBUILD WORKDIR /opt/bitops-local-plugins
# optionally copy all local plugins to the `/opt/bitops-local-plugins`
#    directory within the built container
# bitops.config.yaml is set first to ensure docker does not fail even if
#    the bitops repo's `plugins` directory does not exist
ONBUILD COPY bitops.config.yaml ./plugins .

ONBUILD WORKDIR /opt/bitops
ONBUILD COPY bitops.config.yaml .

ONBUILD RUN python3 scripts/main.py install

ENTRYPOINT ["python3", "/opt/bitops/scripts/main.py", "deploy"]
