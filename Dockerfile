FROM docker:stable-git
LABEL maintainer="Ryan Schlesinger <ryan@outstand.com>"

# COPIED FROM ruby:2.5.1-alpine3.7
# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
# path recommendation: https://github.com/bundler/bundler/pull/6469#issuecomment-383235438
ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"
# (BUNDLE_PATH = GEM_HOME, no need to mkdir/chown both)

ENV DOCKER_COMPOSE_VERSION 1.24.0

RUN addgroup -g 1000 -S ci && \
    adduser -u 1000 -S -s /bin/bash -G ci ci && \
    addgroup -g 1101 docker && \
    addgroup ci docker && \
    apk add --no-cache \
      bash \
      zsh \
      curl \
      jq \
      ruby \
      ruby-bundler \
      py-pip \
      python-dev \
      libffi-dev \
      openssl-dev \
      gcc \
      libc-dev \
      make && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION} && \
    echo 'source /etc/profile' > /home/ci/.bashrc && \
    echo 'source /etc/profile' > /home/ci/.bash_profile && \
    echo 'source /etc/profile' > /root/.bashrc && \
    echo 'source /etc/profile' > /root/.bash_profile && \
    echo $'export FIXUID=$(id -u) \n\
           export FIXGID=$(id -g)' > /etc/profile.d/fixuid.sh && \
    chown ci:ci /srv

ENV GIT_LFS_VERSION 2.7.2
ENV GIT_LFS_HASH 89f5aa2c29800bbb71f5d4550edd69c5f83e3ee9e30f770446436dd7f4ef1d4c
RUN mkdir -p /tmp/build && cd /tmp/build \
  && curl -sSL -o git-lfs.tgz https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-amd64-v${GIT_LFS_VERSION}.tar.gz \
  && echo "${GIT_LFS_HASH}  git-lfs.tgz" | sha256sum -c - \
  && tar -xzf git-lfs.tgz \
  && cp git-lfs /usr/local/bin/ \
  && cd / && rm -rf /tmp/build \
  && git lfs install

USER ci

ENV BUNDLER_VERSION 2.0.1
RUN gem install bundler -v ${BUNDLER_VERSION} --force --no-document

WORKDIR /srv
CMD ["/bin/bash"]
