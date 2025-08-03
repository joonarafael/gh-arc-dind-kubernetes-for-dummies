#!/usr/bin/env bash
set -e

# Script to install Nginx

apt-get update -y
apt-get install -y curl gnupg2 ca-certificates lsb-release

# Add the Nginx signing key
curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg

# Set up the Nginx stable repository
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list


apt-get update -y
apt-get install -y nginx

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Nginx installation completed."
