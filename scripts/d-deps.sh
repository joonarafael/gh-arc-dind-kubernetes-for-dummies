#!/usr/bin/env bash

###########################################################
# SCRIPT TO INSTALL ALL REQUIRED DEPENDENCIES FOR THE SETUP

################
# VALIDATE INPUT

if [ -z "$1" ]; then
  echo "Error: Go version not provided"
  echo "Usage: $0 <go_version> <kind_version>"
  exit 1
fi

GO_VERSION=$1

if [ -z "$2" ]; then
  echo "Error: Kind version not provided"
  echo "Usage: $0 <go_version> <kind_version>"
  exit 1
fi

KIND_VERSION=$2


##############
# BASIC SYSTEM

# Update all packages to the latest version
sudo apt-get update


########
# GOLANG

# Download and install Go
sudo rm -rf /usr/local/go || true

curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

sudo rm -rf go${GO_VERSION}.linux-amd64.tar.gz || true

# Set environment variables
echo "" >> ~/.bashrc
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >> ~/.bashrc

# Sourcing the .bashrc won't work in non-interactive mode
# So we need to extract the lines we need and eval them again
# This is a dirty workaround, but it works
eval "$(cat ~/.bashrc | tail -n +10)"

# Verify installation
go version

curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
rm /tmp/kubectl

# Verify installation
kubectl version --client


######
# KIND

go install sigs.k8s.io/kind@v${KIND_VERSION}

echo "export PATH=\$PATH:/home/${USER}/go/bin" >> ~/.bashrc
eval "$(cat ~/.bashrc | tail -n +10)"

# Verify installation
kind version


######
# HELM

curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh
rm /tmp/get_helm.sh

# Verify installation
helm version
