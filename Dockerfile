FROM ubuntu

ARG NODE_VERSION=latest

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/root/.npm/bin:/usr/n/bin:$PATH \
    NODE_ENV=production \
    NODE_OPTIONS_development="--trace-warnings --trace-uncaught" \
    NODE_OPTIONS_production="--trace-warnings"

WORKDIR /var/local

SHELL [ "/bin/bash", "-l", "-c" ]

ONBUILD USER root
ONBUILD SHELL [ "/bin/bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local/package
ONBUILD ADD . /var/local/package
ONBUILD ENTRYPOINT [ "/bin/bash", "-l", "-c", "eval export NODE_OPTIONS=\\${NODE_OPTIONS_$NODE_ENV} && npm run --script-shell=/bin/bash docker -- \"$@\"", "bash" ]

RUN \
    # setup host
    apt update && apt install -y curl \
    && source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) \
    \
    # install node.js
    && n $NODE_VERSION \
    && n rm $NODE_VERSION \
    \
    # setup node
    && npm config --location=global set prefix /root/.npm \
    && npm config --location=global set cache /root/.npm-cache \
    && npm config --location=global set engine-strict true \
    && npm config --location=global set fund false \
    \
    # make global node modules loadable
    && mkdir -p ~/.npm/lib \
    && rm -rf ~/.node_modules \
    && ln -s ~/.npm/lib/node_modules ~/.node_modules \
    \
    # update npm
    # && npm i -g npm \
    \
    # cleanup
    && curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh | /bin/bash -s -- cleanup

ENTRYPOINT [ "/bin/bash", "-l" ]
