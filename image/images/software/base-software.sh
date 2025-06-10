#!/usr/bin/env bash

# Install base software
apt-get update
apt-get install -y --no-install-recommends \
  apt-transport-https \
  apt-utils \
  ca-certificates \
  curl \
  docker-buildx \
  file \
  gcc \
  git \
  gunicorn \
  iproute2 \
  iptables \
  jq \
  libasound2t64 \
  libgbm-dev \
  libgtk-3-0t64 \
  libgtk2.0-0t64 \
  libnotify-dev \
  libnss3 \
  libnss3-tools \
  libxss1 \
  libxtst6 \
  libyaml-dev \
  locales \
  lsb-release \
  openssl \
  pigz \
  pkg-config \
  psmisc \
  python3 \
  python3-pip \
  python3-venv \
  qemu-system \
  software-properties-common \
  sudo \
  tidy \
  time \
  tzdata \
  uidmap \
  unzip \
  wget \
  xauth \
  xvfb \
  xz-utils