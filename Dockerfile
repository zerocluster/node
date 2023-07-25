FROM ubuntu

ARG NODE_VERSION=latest
ARG NPM_VERSION=latest

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/root/.npm/bin:/usr/n/bin:$PATH

WORKDIR /var/local

SHELL [ "/bin/bash", "-l", "-c" ]

ONBUILD ARG GIT_ID
ONBUILD ENV GIT_ID=$GIT_ID
ONBUILD USER root
ONBUILD SHELL [ "/bin/bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local/package
ONBUILD ADD . /var/local/package
ONBUILD ENTRYPOINT [ "/bin/bash", "-l", "-c", "exec `node -e 'process.stdout.write( require( \"./package.json\" ).scripts?.docker || throw \"Docker script not found in the package.json\" )'` $@", "bash" ]

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
    && npm i --global npm@$NPM_VERSION \
    \
    # cleanup
    && /bin/bash <(curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh) cleanup

ENTRYPOINT [ "/bin/bash", "-l" ]
