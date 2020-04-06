FROM ubuntu:18.04

RUN apt-get update && \
    apt-get -qq -y install sshpass 

FROM microsoft/dotnet:2.1-sdk AS build

FROM node:lts-slim AS node_build 

ARG USER_HOME_DIR="/tmp"
ARG APP_DIR="/app"
ARG USER_ID=1000

#reduce logging, disable angular-cli analytics for ci environment
ENV NPM_CONFIG_LOGLEVEL=warn NG_CLI_ANALYTICS=false

#angular-cli rc0 crashes with .angular-cli.json in user home
ENV HOME "$USER_HOME_DIR"

#not declared to avoid anonymous volume leak
#but when not manually bound to host fs, performance will suffer!
#VOLUME "$USER_HOME_DIR/.cache/yarn"
#VOLUME "$APP_DIR/"
WORKDIR $APP_DIR
EXPOSE 4200

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

RUN apt-get update && apt-get install -qqy --no-install-recommends \
    ca-certificates \
    dumb-init \
    git \
    build-essential \
    python \
    procps \
    rsync \
    curl \
    zip \
    openssh-client \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG NG_CLI_VERSION=9.1.0
LABEL angular-cli=$NG_CLI_VERSION node=$NODE_VERSION

# npm 5 uses different userid when installing packages, as workaround su to node when installing
# see https://github.com/npm/npm/issues/16766
RUN set -xe \
    && mkdir -p $USER_HOME_DIR \
    && chown $USER_ID $USER_HOME_DIR \
    && chmod a+rw $USER_HOME_DIR \
    && mkdir -p $APP_DIR \
    && chown $USER_ID $APP_DIR \
    && chown -R node /usr/local/lib /usr/local/include /usr/local/share /usr/local/bin \
    && (cd "$USER_HOME_DIR"; su node -c "npm install -g @angular/cli@$NG_CLI_VERSION; npm cache clean --force")

USER $USER_ID
