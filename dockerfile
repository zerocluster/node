ARG UBUNTU_VERSION=latest

FROM ubuntu:$UBUNTU_VERSION

ARG NODE_VERSION=lts \
    NPM_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/root/.npm/bin:/usr/n/bin:$PATH

USER root
WORKDIR /var/local
SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ENTRYPOINT [ "/usr/bin/env", "bash", "-l" ]

ONBUILD ARG BUILD_VERSION
ONBUILD ENV BUILD_VERSION=$BUILD_VERSION
ONBUILD USER root
ONBUILD SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local
ONBUILD ENTRYPOINT [ "/usr/bin/env", "bash", "-l" ]

RUN \
    # setup host
    apt-get update && apt-get install -y curl \
    && source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) \
    \
    # install node.js
    && n $NODE_VERSION \
    && n rm $NODE_VERSION \
    \
    # setup node
    && npm config --global set prefix /root/.npm \
    && npm config --global set cache /root/.npm-cache \
    && npm config --global set engine-strict true \
    && npm config --global set fund false \
    && npm config --global set update-notifier false \
    \
    # make global node modules loadable
    && mkdir -p ~/.npm/lib \
    && rm -rf ~/.node_modules \
    && ln -s ~/.npm/lib/node_modules ~/.node_modules \
    \
    # update npm
    && if [[ ! -z $NPM_VERSION ]]; then \
       npm install --global npm@$NPM_VERSION; \
    fi \
    \
    # cleanup
    && /usr/bin/env bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) cleanup
