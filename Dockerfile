#Losely based on devopsil/kops-docker
FROM hashicorp/terraform:0.12.23 AS TERRAFORMV12
FROM hashicorp/terraform:0.11.14 AS TERRAFORMV11


FROM alpine:3.6

ENV KUBECTL_VERSION 1.15.5
ENV HELM_VERSION=3.0.1
ENV RELEASE_ROOT="https://get.helm.sh"
ENV RELEASE_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"

#https://get.helm.sh/helm-v3.0.1-linux-arm64.tar.gz

#install kubectl
RUN apk add --update \
    curl \
    jq \
    vim \
    tar \
    sed \
    git \
    bash \
    wget \
    python \
    python-dev \
    py-pip \
    build-base \
    util-linux pciutils usbutils coreutils binutils findutils grep \
    ca-certificates \
    openssh-client \
    && curl -s -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl \
    && chmod +x /usr/bin/kubectl

RUN pip install shyaml

RUN curl -s -L -o /usr/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x /usr/bin/aws-iam-authenticator

RUN curl -L ${RELEASE_ROOT}/${RELEASE_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm

RUN  helm plugin install https://github.com/hypnoglow/helm-s3.git

COPY --from=TERRAFORMV11 /bin/terraform /usr/bin/terraformv11
COPY --from=TERRAFORMV12 /bin/terraform /usr/bin/terraformv12


CMD ["/bin/bash"]
