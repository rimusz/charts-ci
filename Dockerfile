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

FROM quay.io/helmpack/chart-testing:v3.5.0

RUN apk add bash tree curl wget

ENV PATH /google-cloud-sdk/bin:$PATH
ARG CLOUD_SDK_VERSION=367.0.0
RUN curl -LO "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz" && \
    tar xzf "google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz" && \
    rm "google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz" && \
    ln -s /lib /lib64 && \
    rm -rf /google-cloud-sdk/.install/.backup && \
    gcloud version

ARG AWS_IAM_AUTHENTICATOR_URL=https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator

ADD ${AWS_IAM_AUTHENTICATOR_URL} /usr/local/bin/aws-iam-authenticator
RUN chmod +x /usr/local/bin/aws-iam-authenticator

ARG YQ_URL=https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64

ADD ${YQ_URL} /usr/local/bin/yq
RUN chmod +x /usr/local/bin/yq

RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

WORKDIR /workdir
