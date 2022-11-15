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

FROM --platform=${TARGETPLATFORM} quay.io/helmpack/chart-testing:v3.7.1

ARG TARGETARCH
ARG YQ_VERSION=3.4.1
ARG KUBECTL_VERSION=1.23.10
ARG CLOUD_SDK_VERSION=409.0.0
ARG AWS_IAM_AUTHENTICATOR_VERSION=0.5.9

RUN apk add tree wget

# Override kubectl
# https://github.com/aws/aws-cli/issues/6920
LABEL KUBECTL_VERSION=${KUBECTL_VERSION}
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

ENV PATH /google-cloud-sdk/bin:$PATH
ENV CLOUDSDK_PYTHON=/usr/bin/python3
RUN if [[ "${TARGETARCH}" == "arm64" ]] ; then export GOOGLE_SDK_ARCH="arm" ; else export GOOGLE_SDK_ARCH="x86_64" ; fi && \
    curl -LO "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${GOOGLE_SDK_ARCH}.tar.gz" && \
    tar xzf "google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${GOOGLE_SDK_ARCH}.tar.gz" && \
    rm "google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-${GOOGLE_SDK_ARCH}.tar.gz" && \
    ln -s /lib /lib64 && \
    ln -s /usr/bin/python3 /google-cloud-sdk/bin/python3 && \
    rm -rf /google-cloud-sdk/.install/.backup && \
    gcloud version

ARG AWS_IAM_AUTHENTICATOR_URL=https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_${TARGETARCH}
ADD ${AWS_IAM_AUTHENTICATOR_URL} /usr/local/bin/aws-iam-authenticator
RUN chmod +x /usr/local/bin/aws-iam-authenticator

ARG YQ_URL=https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}
ADD ${YQ_URL} /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq

RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

WORKDIR /workdir
