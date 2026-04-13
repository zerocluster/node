FROM ghcr.io/zerocluster/node

USER root
WORKDIR /var/local
SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]

ONBUILD ARG BUILD_VERSION
ONBUILD ENV BUILD_VERSION=$BUILD_VERSION

ONBUILD SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ONBUILD ENTRYPOINT [ "/usr/bin/env", "bash", "-l", "-c", "exec signals-manager node bin/main.js $@", "bash" ]

ONBUILD USER root
ONBUILD WORKDIR /var/local/package
ONBUILD ADD . /var/local/package

ONBUILD HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    --start-interval=5s \
    --retries=3 \
    CMD curl -fsS "http://127.0.0.1:82/"
