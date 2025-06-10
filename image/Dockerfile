FROM ubuntu:24.04 AS build

#
# ARGS & ENV
#

# GitHub runner arguments
ARG RUNNER_VERSION=2.325.0
ARG RUNNER_CONTAINER_HOOKS_VERSION=0.7.0

# Docker and Compose arguments
ARG DOCKER_VERSION=28.2.1
ARG COMPOSE_VERSION=v2.37.0

# Dumb-init version
ARG DUMB_INIT_VERSION=1.2.5

# Golang & Node
ARG GO_VERSION=1.24.4
ARG NODE_VERSION=22

# Other arguments, expose TARGETPLATFORM for multi-arch builds
ARG DEBUG=false
ARG TARGETPLATFORM

# Set environment variables needed at build or run
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_MANUALLY_TRAP_SIG=1
ENV ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT=1

# Copy in environment variables not needed at build
COPY images/.env /.env

# Shell setup
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#
# BASE SOFTWARE & JOBBA CI/CD DEPENDENCIES
#

# Install base software & libraries
COPY images/software/base-software.sh /base-libs.sh
RUN bash /base-libs.sh && rm /base-libs.sh

#
# RUNNER SPECIFIC
#

# Runner user
RUN if id 1000 >/dev/null 2>&1; then userdel -r $(id -nu 1000) 2>/dev/null || true; fi \
  && adduser --disabled-password --gecos "" --uid 1000 runner \
  && usermod -aG sudo runner \
  && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers

# Make and set the working directory
RUN mkdir -p /home/runner \
  && chown -R runner:runner /home/runner

WORKDIR /home/runner

#
# ADDITIONALLY REQUIRED SOFTWARE
#

# Install GitHub CLI
COPY images/software/gh-cli.sh /gh-cli.sh
RUN bash /gh-cli.sh && rm /gh-cli.sh

# Install kubectl
COPY images/software/kubectl.sh /kubectl.sh
RUN bash /kubectl.sh && rm /kubectl.sh

# Install helm
COPY images/software/get-helm.sh /helm.sh
RUN bash /helm.sh && rm /helm.sh

#
# OTHER OPTIONAL SOFTWARE
#

# Install Go
COPY images/software/get-go.sh /go.sh
RUN bash /go.sh "${GO_VERSION}" && rm /go.sh

# Install Caddy
COPY images/software/get-caddy.sh /caddy.sh
RUN bash /caddy.sh && rm /caddy.sh

# Install Node & Yarn
COPY images/software/get-node-yarn.sh /node-yarn.sh
RUN bash /node-yarn.sh "${NODE_VERSION}" && rm /node-yarn.sh

# Install AWS CLI
COPY images/software/get-awscli.sh /awscli.sh
RUN ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && if [ "$ARCH" = "arm64" ]; then export AWSCLI_ARCH=aarch64 ; else export AWSCLI_ARCH=x86_64 ; fi \
  && echo "Architecture for AWS CLI: $AWSCLI_ARCH" \
  && bash /awscli.sh "$AWSCLI_ARCH" && rm /awscli.sh

#
# PYTHON
#

# Python is installed through the base-software.sh script
# Just ensure `python3` is the default `python`
RUN ln -sf /usr/bin/python3 /usr/bin/python \
  && ln -sf /usr/bin/pip3 /usr/bin/pip
RUN python --version && pip --version

#
# DOCKER
#

# Install Docker
RUN export DOCKER_ARCH=x86_64 \
  && if [ "$RUNNER_ARCH" = "arm64" ]; then export DOCKER_ARCH=aarch64 ; fi \
  && curl -fLo docker.tgz https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz \
  && tar zxvf docker.tgz \
  && rm -rf docker.tgz

RUN install -o root -g root -m 755 docker/* /usr/bin/ && rm -rf docker

# Runner download supports amd64 as x64
RUN export ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && echo "ARCH: $ARCH" \
  && if [ "$ARCH" = "amd64" ]; then export ARCH=x64 ; fi \
  && curl -L -o runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./runner.tar.gz \
  && rm runner.tar.gz \
  && ./bin/installdependencies.sh \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

# Install container hooks required for the runner set
RUN curl -f -L -o runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip \
  && unzip ./runner-container-hooks.zip -d ./k8s \
  && rm runner-container-hooks.zip

# Install dumb-init, arch command on OS X reports "i386" for Intel CPUs regardless of bitness
RUN ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export ARCH \
  && if [ "$ARCH" = "arm64" ]; then export ARCH=aarch64 ; fi \
  && if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "i386" ]; then export ARCH=x86_64 ; fi \
  && curl -f -L -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_${ARCH} \
  && chmod +x /usr/local/bin/dumb-init

# Make the rootless runner directory and externals directory executable
RUN mkdir -p /run/user/1000 \
  && chown runner:runner /run/user/1000 \
  && chmod a+x /run/user/1000 \
  && mkdir -p /home/runner/externals \
  && chown runner:runner /home/runner/externals \
  && chmod a+x /home/runner/externals

# docker-compose installation
# NOTE: All Docker Compose commands have to be executed with `docker-compose` in the workflow!
RUN ARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export ARCH \
  && if [ "$ARCH" = "arm64" ]; then export ARCH=aarch64 ; fi \
  && if [ "$ARCH" = "amd64" ]; then export ARCH=x86_64 ; fi \
  && curl --create-dirs -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-${ARCH}" -o /home/runner/bin/docker-compose ; \
  chmod +x /home/runner/bin/docker-compose

#
# POST-INSTALL
#

# Cleanup
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

FROM scratch AS final

# Labels
LABEL org.opencontainers.image.source="https://github.com/joonarafael/gh-arc-dind-kubernetes-for-dummies"
LABEL org.opencontainers.image.title="custom-rootless-ubuntu-noble"
LABEL org.opencontainers.image.description="A customized Ubuntu Noble (24.04 LTS) -based runner image for GitHub Actions, rootless"
LABEL org.opencontainers.image.authors="Joona Kettunen (@joonarafael), Natalie Somersall (@some-natalie)"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.documentation="https://github.com/joonarafael/gh-arc-dind-kubernetes-for-dummies/blob/master/image/README.md"

ENV HOME=/home/runner
ENV PATH="${PATH}:${HOME}/.local/bin:/home/runner/bin"
ENV ImageOS=ubuntu24

USER runner

COPY --from=build / /

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]