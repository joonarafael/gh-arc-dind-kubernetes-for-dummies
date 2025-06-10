#!/usr/bin/env bash

######################################
# RUNNER SETUP SCRIPT

# This script is controlling all the other setup scripts.


################
# VALIDATE INPUT

if [ -z "$1" ]; then
  echo "Error: Go version not provided"
  echo "Usage: $0 <go_version> <kind_version> <github_config_url> <github_pat>"
  exit 1
fi

GO_VERSION=$1

if [ -z "$2" ]; then
  echo "Error: Kind version not provided"
  echo "Usage: $0 <go_version> <kind_version> <github_config_url> <github_pat>"
  exit 1
fi

KIND_VERSION=$2

if [ -z "$3" ]; then
  echo "Error: GitHub config URL not provided"
  echo "Usage: $0 <go_version> <kind_version> <github_config_url> <github_pat>"
  exit 1
fi

GITHUB_CONFIG_URL=$3

if [ -z "$4" ]; then
  echo "Error: GitHub PAT not provided"
  echo "Usage: $0 <go_version> <kind_version> <github_config_url> <github_pat>"
  exit 1
fi

GITHUB_PAT=$4

./d-deps.sh $GO_VERSION $KIND_VERSION
./e-clusters.sh $GITHUB_CONFIG_URL $GITHUB_PAT
