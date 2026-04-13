ARG UBUNTU_VERSION=latest

FROM ubuntu:$UBUNTU_VERSION

ARG NODE_VERSION=lts-latest
ARG NPM_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/root/.local/share/fnm/current/bin:$PATH

USER root
WORKDIR /var/local
SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ENTRYPOINT [ "/usr/bin/env", "bash", "-l" ]

ONBUILD ARG BUILD_VERSION
ONBUILD ENV BUILD_VERSION=$BUILD_VERSION

ONBUILD SHELL [ "/usr/bin/env", "bash", "-l", "-c" ]
ONBUILD ENTRYPOINT [ "/usr/bin/env", "bash", "-l" ]

ONBUILD USER root
ONBUILD WORKDIR /var/local

RUN <<EOF
#!/usr/bin/env bash

# setup host
apt-get update && apt-get install -y curl
script=$(curl -fsSL "https://raw.githubusercontent.com/softvisio/scripts/main/setup-host.sh")
source <(echo "$script")

# install signals-manager
curl -fsSLo "/usr/bin/signals-manager" "https://raw.githubusercontent.com/softvisio/scripts/main/signals-manager.js"
chmod +x "/usr/bin/signals-manager"

# install node.js
fnm use --install-if-missing $NODE_VERSION

# update npm
if [[ -n ${NPM_VERSION:-} ]]; then
   npm install --global npm@$NPM_VERSION
fi

# cleanup
script=$(curl -fsSL "https://raw.githubusercontent.com/softvisio/scripts/main/env-build-node.sh")
bash <(echo "$script") cleanup

EOF
