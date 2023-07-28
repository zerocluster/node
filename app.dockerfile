FROM ghcr.io/zerocluster/node

USER root
WORKDIR /var/local
SHELL [ "/bin/bash", "-l", "-c" ]
ENTRYPOINT [ "/bin/bash", "-l" ]

ONBUILD ARG GIT_ID
ONBUILD ENV GIT_ID=$GIT_ID
ONBUILD USER root
ONBUILD SHELL [ "/bin/bash", "-l", "-c" ]
ONBUILD WORKDIR /var/local/package
ONBUILD ADD . /var/local/package

ONBUILD ENTRYPOINT [ "/bin/bash", "-l", "-c", "exec `node -e 'process.stdout.write( require( \"./package.json\" ).scripts?.docker || \"Docker script not found in the package.json\" )'` $@", "bash" ]

ONBUILD HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    # --start-interval=5s \ # XXX unknown option
    --retries=3 \
    CMD curl -f http://127.0.0.1:91/ || exit 1
