#!/usr/bin/env bash

# Script to install Golang

# Check if version argument is provided
if [ -z "$1" ]; then
  echo "Error: Go version not provided"
  echo "Usage: $0 <go_version>"
  exit 1
fi

GO_VERSION=$1
echo "Installing Go version ${GO_VERSION}..."

# Download and install Go
curl -L "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
ln -s /usr/local/go/bin/go /usr/local/bin/go
ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Set environment variables
echo "export GOPATH=/go" >> /etc/profile.d/go.sh
echo "export PATH=\$GOPATH/bin:/usr/local/go/bin:\$PATH" >> /etc/profile.d/go.sh
chmod +x /etc/profile.d/go.sh

# Source the environment file for this session
source /etc/profile.d/go.sh

# Verify installation
go version

echo "Go ${GO_VERSION} installed successfully!"
