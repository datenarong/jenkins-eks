FROM jenkins/jenkins:2.412
LABEL maintainer="datenarong@gmail.com"

USER root
ENV KUBE_VERSION v1.21.2
ENV HELM_VERSION 3.9.4-1
ENV AWSCLI_VERSION 2.10.0
ENV GO_VERSION 1.16.8

# Install kubectl
RUN \
  echo "Update the apt package index and install packages needed to use the Kubernetes apt repository"; \
  apt-get update; \
  apt-get install -y \
    ca-certificates \
    curl \
    apt-transport-https; \
  \
  echo "Download the Google Cloud public signing key"; \
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg; \
  \
  echo "Add the Kubernetes apt repository"; \
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list; \
  \
  echo "Update apt package index with the new repository and install kubectl"; \
  apt-get update; \
  apt-get install -y kubectl;

# Install Helm
RUN \
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null; \
  echo "Update the apt package index and install packages needed to use the Helm apt repository"; \
  apt-get install -y \
    apt-transport-https; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list; \
  apt-get update; \
  apt-get install helm=${HELM_VERSION};

# Install aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o "awscliv2.zip" \
  curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip.sig; \
  gpg --verify awscliv2.sig awscliv2.zip; \
  unzip awscliv2.zip; \
  ./aws/install;

# Install Docker-CE
RUN \
  echo "Update the apt package index and install packages to allow apt to use a repository over HTTPS"; \
  apt-get update; \
  apt-get install -y \
    ca-certificates \
    curl \
    gnupg; \
  \
  echo "Add Docker's official GPG key"; \
  install -m 0755 -d /etc/apt/keyrings; \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
  chmod a+r /etc/apt/keyrings/docker.gpg; \
  \
  echo "Set up the repository"; \
  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
  \
  echo "Install the latest version"; \
  apt-get update; \
  apt-get install -y \
    docker-ce;

# Install Go
RUN \
  apt-get update; \
  apt-get install -y \
    wget; \
  wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz; \
  tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz; \
  ln -s /usr/local/go/bin/go /usr/bin/go;
