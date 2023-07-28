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
