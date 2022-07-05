############################################
#   Global ARGs ############################
##  Versions    ############################
ARG TF_VERSION=1.2.3
#
ARG TF_VSPHERE_VER=2.2.0
ARG TF_GITHUB_VER=4.26.1
ARG TF_GITLAB_VER=3.15.1
ARG TF_YC_VER=0.75.0
ARG TF_DO_VER=2.21.0
ARG TF_AWS_VER=4.21.0
ARG TF_LOCAL_VER=2.2.3
ARG TF_RANDOM_VER=3.3.2
#
##  Names    ###############################
ARG TF_VSPHERE=terraform-provider-vsphere
ARG TF_GITHUB=terraform-provider-github
ARG TF_GITLAB=terraform-provider-gitlab
ARG TF_YC=terraform-provider-yandex
ARG TF_DO=terraform-provider-digitalocean
ARG TF_AWS=terraform-provider-aws
ARG TF_LOCAL=terraform-provider-local
ARG TF_RANDOM=terraform-provider-random
#
############################################

FROM golang:latest as builder

#   https://github.com/hashicorp/terraform/
ARG TF_VERSION
ARG TF_SRC=https://github.com/hashicorp/terraform/archive/refs/tags/v${TF_VERSION}.zip

#   https://github.com/hashicorp/terraform-provider-vsphere/
ARG TF_VSPHERE
ARG TF_VSPHERE_VER
ARG TF_VSPHERE_SRC=https://github.com/hashicorp/${TF_VSPHERE}/archive/refs/tags/v${TF_VSPHERE_VER}.zip

#   https://github.com/integrations/terraform-provider-github/
ARG TF_GITHUB
ARG TF_GITHUB_VER
ARG TF_GITHUB_SRC=https://github.com/integrations/${TF_GITHUB}/archive/refs/tags/v${TF_GITHUB_VER}.zip

#   https://github.com/gitlabhq/terraform-provider-gitlab
ARG TF_GITLAB
ARG TF_GITLAB_VER
ARG TF_GITLAB_SRC=https://github.com/gitlabhq/${TF_GITLAB}/archive/refs/tags/v${TF_GITLAB_VER}.zip

#   https://github.com/yandex-cloud/terraform-provider-yandex
ARG TF_YC
ARG TF_YC_VER
ARG TF_YC_SRC=https://github.com/yandex-cloud/${TF_YC}/archive/refs/tags/v${TF_YC_VER}.zip

#   https://github.com/digitalocean/terraform-provider-digitalocean
ARG TF_DO
ARG TF_DO_VER
ARG TF_DO_SRC=https://github.com/digitalocean/${TF_DO}/archive/refs/tags/v${TF_DO_VER}.zip

#   https://github.com/hashicorp/terraform-provider-aws/
ARG TF_AWS
ARG TF_AWS_VER
ARG TF_AWS_SRC=https://github.com/hashicorp/${TF_AWS}/archive/refs/tags/v${TF_AWS_VER}.zip

#   https://github.com/hashicorp/terraform-provider-local/
ARG TF_LOCAL
ARG TF_LOCAL_VER
ARG TF_LOCAL_SRC=https://github.com/hashicorp/${TF_LOCAL}/archive/refs/tags/v${TF_LOCAL_VER}.zip

#   https://github.com/hashicorp/terraform-provider-random/
ARG TF_RANDOM
ARG TF_RANDOM_VER
ARG TF_RANDOM_SRC=https://github.com/hashicorp/${TF_RANDOM}/archive/refs/tags/v${TF_RANDOM_VER}.zip

WORKDIR /tmp

ADD ${TF_SRC} ./terraform.zip
ADD ${TF_VSPHERE_SRC} ./vsphere.zip
ADD ${TF_GITHUB_SRC} ./github.zip
ADD ${TF_GITLAB_SRC} ./gitlab.zip
ADD ${TF_YC_SRC} ./yc.zip
ADD ${TF_DO_SRC} ./do.zip
ADD ${TF_AWS_SRC} ./aws.zip
ADD ${TF_LOCAL_SRC} ./local.zip
ADD ${TF_RANDOM_SRC} ./random.zip

RUN apt update && \
    apt install unzip

RUN unzip terraform.zip && cd terraform-${TF_VERSION} && \
    go build -o /tmp/bin/terraform

RUN unzip vsphere.zip && cd ${TF_VSPHERE}-${TF_VSPHERE_VER} && \
    go build -o /tmp/bin/${TF_VSPHERE}_${TF_VSPHERE_VER} && \
    cd ../

RUN unzip github.zip && cd ${TF_GITHUB}-${TF_GITHUB_VER} && \
    go build -o /tmp/bin/${TF_GITHUB}_${TF_GITHUB_VER} && \
    cd ../

RUN unzip gitlab.zip && cd ${TF_GITLAB}-${TF_GITLAB_VER} && \
    go build -o /tmp/bin/${TF_GITLAB}_${TF_GITLAB_VER} && \
    cd ../

RUN unzip yc.zip && cd ${TF_YC}-${TF_YC_VER} && \
    go build -o /tmp/bin/${TF_YC}_${TF_YC_VER} && \
    cd ../

RUN unzip do.zip && cd ${TF_DO}-${TF_DO_VER} && \
    go build -o /tmp/bin/${TF_DO}_${TF_DO_VER} && \
    cd ../

RUN unzip aws.zip && cd ${TF_AWS}-${TF_AWS_VER} && \
    go build -o /tmp/bin/${TF_AWS}_${TF_AWS_VER} && \
    cd ../

RUN unzip local.zip && cd ${TF_LOCAL}-${TF_LOCAL_VER} && \
    go build -o /tmp/bin/${TF_LOCAL}_${TF_LOCAL_VER} && \
    cd ../

RUN unzip random.zip && cd ${TF_RANDOM}-${TF_RANDOM_VER} && \
    go build -o /tmp/bin/${TF_RANDOM}_${TF_RANDOM_VER} && \
    cd ../

FROM ubuntu:22.04

ARG ARCH=linux_amd64

ARG TF_VSPHERE
ARG TF_VSPHERE_VER

ARG TF_GITHUB
ARG TF_GITHUB_VER

ARG TF_GITLAB
ARG TF_GITLAB_VER

ARG TF_YC
ARG TF_YC_VER

ARG TF_DO
ARG TF_DO_VER

ARG TF_AWS
ARG TF_AWS_VER

ARG TF_LOCAL
ARG TF_LOCAL_VER

ARG TF_RANDOM
ARG TF_RANDOM_VER

ENV TF_PLUGINS_DIR=/root/.terraform.d/plugins/local

COPY --from=builder /tmp/bin/terraform /usr/sbin/
COPY --from=builder /tmp/bin/${TF_VSPHERE}_${TF_VSPHERE_VER} ${TF_PLUGINS_DIR}/hashicorp/vsphere/${TF_VSPHERE_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_GITHUB}_${TF_GITHUB_VER} ${TF_PLUGINS_DIR}/integrations/github/${TF_GITHUB_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_GITLAB}_${TF_GITLAB_VER} ${TF_PLUGINS_DIR}/gitlabhq/gitlab/${TF_GITLAB_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_YC}_${TF_YC_VER} ${TF_PLUGINS_DIR}/yandex-cloud/yandex/${TF_YC_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_DO}_${TF_DO_VER} ${TF_PLUGINS_DIR}/digitalocean/digitalocean/${TF_DO_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_AWS}_${TF_AWS_VER} ${TF_PLUGINS_DIR}/hashicorp/aws/${TF_AWS_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_LOCAL}_${TF_LOCAL_VER} ${TF_PLUGINS_DIR}/hashicorp/local/${TF_LOCAL_VER}/${ARCH}/
COPY --from=builder /tmp/bin/${TF_RANDOM}_${TF_RANDOM_VER} ${TF_PLUGINS_DIR}/hashicorp/random/${TF_RANDOM_VER}/${ARCH}/

RUN apt update && \
    apt install -y git tree vim mc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /terraform

RUN ln -s ${TF_PLUGINS_DIR} /terraform/plugins

ENTRYPOINT [ "bash" ]
