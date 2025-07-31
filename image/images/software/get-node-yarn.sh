#!/usr/bin/env bash

# Get Node.js version from argument or use default
NODE_VERSION=${1:-22}

echo "Installing Node.js ${NODE_VERSION}.x and Yarn..."

# Install Node.js
curl -sL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" -o /tmp/nodesource_setup.sh
chmod u+x /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
apt-get install nodejs -y --no-install-recommends

# Install Yarn globally
npm install --global yarn

# Enable Yarn 4.9.2
yarn set version 4.9.2

# Verify installations
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"
echo "Yarn version: $(yarn --version)"

echo "Node.js and Yarn installation complete!" 
