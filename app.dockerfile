FROM ghcr.io/zerocluster/node

ENV ENTRYPOINT="node bin/main.js"

USER root
WORKDIR /var/local
SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]

ONBUILD ARG GITHUB_TOKEN
ONBUILD ARG NPM_TOKEN_NPMJS
ONBUILD ARG NPM_TOKEN_GITHUB

ONBUILD ARG BUILD_VERSION
ONBUILD ENV BUILD_VERSION=$BUILD_VERSION

ONBUILD USER root
ONBUILD SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local/package
ONBUILD ADD . /var/local/package

ONBUILD ENTRYPOINT [ "/usr/bin/env", "bash", "-l", "-c", "exec $ENTRYPOINT $@", "bash" ]

ONBUILD HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    --start-interval=5s \
    --retries=3 \
    CMD curl -fsS "http://127.0.0.1:82/"
