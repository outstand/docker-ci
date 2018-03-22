FROM docker:stable-git
LABEL maintainer="Ryan Schlesinger <ryan@outstand.com>"

ENV DOCKER_COMPOSE_VERSION 1.20.1

RUN apk add --no-cache \
      bash \
      py-pip && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION}
