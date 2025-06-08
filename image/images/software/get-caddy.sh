#!/usr/bin/env bash

# Script to install Caddy reverse proxy

apt-get update -y 
apt-get install -y --no-install-recommends debian-keyring debian-archive-keyring

curl -1sLf "https://dl.cloudsmith.io/public/caddy/stable/gpg.key" | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf "https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt" | tee /etc/apt/sources.list.d/caddy-stable.list

apt-get update -u
apt-get install -y --no-install-recommends caddy
