#!/usr/bin/env bash

# Script to install AWS CLI

# Use architecture passed as parameter or detect it
if [ -n "$1" ]; then
    AWSCLI_ARCH="$1"
else
    # Fallback to detection if no parameter provided
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        AWSCLI_ARCH="x86_64"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        AWSCLI_ARCH="aarch64"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
fi

echo "Installing AWS CLI for architecture: $AWSCLI_ARCH"
curl "https://awscli.amazonaws.com/awscli-exe-linux-$AWSCLI_ARCH.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
aws --version