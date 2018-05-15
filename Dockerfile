FROM docker:stable-git
LABEL maintainer="Ryan Schlesinger <ryan@outstand.com>"

ENV DOCKER_COMPOSE_VERSION 1.21.2

RUN apk add --no-cache \
      bash \
      zsh \
      curl \
      jq \
      py-pip && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION} && \
    curl -o /usr/local/bin/circleci https://circle-downloads.s3.amazonaws.com/releases/build_agent_wrapper/circleci && \
    chmod +x /usr/local/bin/circleci
