#!/usr/bin/env bash
set -xe

apt-get update -y && \
add-apt-repository ppa:deadsnakes/ppa && \
add-apt repostiory "deb [arch=amd64] http://archive.ubuntu.com/ubuntu $(lsb_release -cs) stable" && \
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
apt-get update && \
apt-get install -y software-properties-common libsodium-dev curl jq python3.7 mysql-client
pip install \
  docker-compose==1.12.0 \
  awscli==1.17.7
