FROM docker:stable-git
LABEL maintainer="Ryan Schlesinger <ryan@outstand.com>"

ENV DOCKER_COMPOSE_VERSION 1.22.0

RUN addgroup -g 1000 -S ci && \
    adduser -u 1000 -S -s /bin/bash -G ci ci && \
    apk add --no-cache \
      bash \
      zsh \
      curl \
      jq \
      py-pip && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION} && \
    echo 'source /etc/profile' > /home/ci/.bashrc && \
    echo 'source /etc/profile' > /home/ci/.bash_profile && \
    echo 'source /etc/profile' > /root/.bashrc && \
    echo 'source /etc/profile' > /root/.bash_profile && \
    echo $'export FIXUID=$(id -u) \n\
           export FIXGID=$(id -g)' > /etc/profile.d/fixuid.sh

USER ci
CMD ["/bin/bash"]
