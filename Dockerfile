# Copyright The Helm Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM quay.io/helmpack/chart-testing:v3.7.1

# Override kubectl 
# https://github.com/aws/aws-cli/issues/6920
ARG kubectl_version=v1.23.10
LABEL kubectl_version=$kubectl_version
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$kubectl_version/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

RUN apk add bash tree curl wget

ENV PATH /google-cloud-sdk/bin:$PATH
ARG CLOUD_SDK_VERSION=403.0.0
RUN curl -LO "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz" && \
    tar xzf "google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz" && \
    rm "google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz" && \
    ln -s /lib /lib64 && \
    rm -rf /google-cloud-sdk/.install/.backup && \
    gcloud version

ARG AWS_IAM_AUTHENTICATOR_URL=https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64
ADD ${AWS_IAM_AUTHENTICATOR_URL} /usr/local/bin/aws-iam-authenticator
RUN chmod +x /usr/local/bin/aws-iam-authenticator

ARG YQ_URL=https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

ADD ${YQ_URL} /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq

RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

WORKDIR /workdir
