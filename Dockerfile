FROM ubuntu

ARG NODE_VERSION \
    NPM_VERSION

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
    && IF [[ ! -z $NPM_VERSION ]] npm i --global npm@$NPM_VERSION; \
    \
    # cleanup
    && /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) cleanup
