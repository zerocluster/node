ARG UBUNTU_VERSION
ARG    NODE_VERSION=aaaa
ARG    NPM_VERSION

FROM ubuntu:$UBUNTU_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/root/.npm/bin:/usr/n/bin:$PATH

USER root
WORKDIR /var/local
SHELL [ "/bin/bash", "-l", "-c" ]
ENTRYPOINT [ "/bin/bash", "-l" ]

ONBUILD ARG GIT_ID
ONBUILD ENV GIT_ID=$GIT_ID
ONBUILD USER root
ONBUILD SHELL [ "/bin/bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local
ONBUILD ENTRYPOINT [ "/bin/bash", "-l" ]

RUN \
    # setup host
    echo "--- ubunt: ${UBUNTU_VERSION} ==" \
    && echo --- node: ${NODE_VERSION} \
    && exit 1 \
    \
    && apt-get update && apt-get install -y curl \
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
       npm i --global npm@$NPM_VERSION; \
    fi \
    \
    # cleanup
    && /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) cleanup
