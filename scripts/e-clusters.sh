#!/usr/bin/env bash

###########
# CONSTANTS

NAMESPACE_SYSTEMS="arc-systems"
NAMESPACE_RUNNERS="arc-runners"

VERSION="0.11.0"
INSTALLATION_NAME="self-hosted-runners"

################
# VALIDATE INPUT

if [ -z "$1" ]; then
  echo "Error: GitHub config URL not provided"
  echo "Usage: $0 <github_config_url> <github_pat>"
  exit 1
fi

GITHUB_CONFIG_URL=$1

if [ -z "$2" ]; then
  echo "Error: GitHub PAT not provided"
  echo "Usage: $0 <github_config_url> <github_pat>"
  exit 1
fi

GITHUB_PAT=$2


####################
# SOURCE ENVIRONMENT

eval "$(cat ~/.bashrc | tail -n +10)"


##############
# KIND CLUSTER

kind create cluster


###############
# CONFIG VALUES

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
FILENAME="values.yml"
FILE_PATH="$SCRIPT_DIR/$FILENAME"

if [ -f "$FILE_PATH" ]; then
    echo "The file '$FILENAME' exists next to the script. Applying the values..."
else
    echo "Error: The file '$FILENAME' does not exist next to the script. Downloading the default one..."
    curl -LO https://raw.githubusercontent.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/refs/heads/master/values.yml
fi

helm install arc \
    --version "${VERSION}" \
    --namespace "${NAMESPACE_SYSTEMS}" \
    --create-namespace \
    -f values.yml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

helm install "${INSTALLATION_NAME}" \
    --version "${VERSION}" \
    --namespace "${NAMESPACE_RUNNERS}" \
    --create-namespace \
    -f values.yml \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

echo ""
echo ""

echo "Listing all installed Helm charts..."
helm list -A

echo ""
echo ""

echo "Listing all installed Kubernetes resources..."
kubectl get pods -n arc-systems

echo ""
echo ""

echo "Script execution finished. If no errors were reported, you can now start using the runner set."
echo ""
echo "For your GitHub repository $GITHUB_CONFIG_URL, you should soon see the runner set in the Actions tab."
echo "If you don't see it, check the logs of the runner set in the namespace."

echo ""
echo ""

echo "You may have to source your environment again with 'source ~/.bashrc' to get some of the newly installed tools to work."
