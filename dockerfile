ARG UBUNTU_VERSION=latest

FROM ubuntu:$UBUNTU_VERSION

ARG NODE_VERSION=lts-latest
ARG NPM_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/root/.local/share/fnm/current/bin:$PATH

USER root
WORKDIR /var/local
SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ENTRYPOINT [ "/usr/bin/env", "bash", "-l" ]

ONBUILD ARG GITHUB_TOKEN
ONBUILD ARG NPM_TOKEN_NPMJS
ONBUILD ARG NPM_TOKEN_GITHUB

ONBUILD ARG BUILD_VERSION
ONBUILD ENV BUILD_VERSION=$BUILD_VERSION

ONBUILD USER root
ONBUILD SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local
ONBUILD ENTRYPOINT [ "/usr/bin/env", "bash", "-l" ]

RUN \
    # setup host
    apt-get update && apt-get install -y curl \
    && script=$(curl -fsSL "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh") \
    && source <(echo "$script") \
    \
    # install node.js
    && fnm use --install-if-missing $NODE_VERSION \
    \
    # update npm
    && if [[ -n ${NPM_VERSION:-} ]]; then \
       npm install --global npm@$NPM_VERSION; \
    fi \
    \
    # cleanup
    && script=$(curl -fsSL "https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh") \
    && bash <(echo "$script") cleanup
