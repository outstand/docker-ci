FROM docker:stable-git
LABEL maintainer="Ryan Schlesinger <ryan@outstand.com>"

ENV DOCKER_COMPOSE_VERSION 1.22.0

RUN apk add --no-cache \
      bash \
      zsh \
      curl \
      jq \
      py-pip && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION}

ENV ENV /etc/profile

RUN echo $'export FIXUID=$(id -u) \n\
           export FIXGID=$(id -g)' > /etc/profile.d/fixuid.sh
