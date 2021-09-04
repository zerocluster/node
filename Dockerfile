FROM centos:latest

USER root

ENV TZ=UTC \
    PATH=$PATH:/root/.npm/bin:/usr/n/bin

WORKDIR /var/local

SHELL [ "/bin/bash", "-l", "-c" ]

ONBUILD USER root
ONBUILD SHELL [ "/bin/bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local/package
ONBUILD ADD . /var/local/package
ONBUILD ENTRYPOINT [ "/bin/bash", "-l", "-c", "node bin/main.js \"$@\"", "bash" ]
ONBUILD HEALTHCHECK \
    --start-period=30s \
    --interval=30s \
    --retries=3 \
    --timeout=10s \
    CMD curl -f http://127.0.0.1/api/healthcheck || exit 1

RUN \
    # setup host
    source <( curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh ) \
    \
    # install latest node
    && n latest \
    && n rm latest \
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
    # cleanup node build environment
    && curl -fsSL https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh | /bin/bash -s -- cleanup

ENTRYPOINT [ "/bin/bash", "-l" ]
