#!/usr/bin/env bash

# Script to install Node.js and Yarn Berry

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

# Set up Yarn for the runner user properly
# Create runner home directory if it doesn't exist
mkdir -p /home/runner

# Enable Yarn 4.9.2 globally (system-wide installation)
yarn set version 4.9.2 --install-mode update-lockfile

# Ensure runner user owns their home directory and has proper permissions
chown -R runner:runner /home/runner || true

# Set up Yarn cache directory with proper permissions
mkdir -p /home/runner/.yarn
chown -R runner:runner /home/runner/.yarn || true
chmod -R 755 /home/runner/.yarn || true

# Verify installations
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"
echo "Yarn version: $(yarn --version)"

echo "Node.js and Yarn installation complete!" 
