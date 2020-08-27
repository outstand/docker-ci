FROM buildpack-deps:buster
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

ENV DOCKER_COMPOSE_VERSION 1.26.2

RUN groupadd -g 1000 --system ci && \
    useradd -u 1000 -g ci -ms /bin/bash --system ci && \
    groupadd -g 1101 docker && \
    usermod -a -G docker ci && \
    apt-get update && apt-get install -y --no-install-recommends \
      zsh \
      jq \
      ruby \
      ruby-bundler \
      python3-dev \
      python3-setuptools \
      python3-pip \
    && rm -rf /var/lib/apt/lists/* && \
    pip3 install docker-compose==${DOCKER_COMPOSE_VERSION} && \
    echo 'source /etc/profile' > /home/ci/.bashrc && \
    echo 'source /etc/profile' > /home/ci/.bash_profile && \
    echo 'source /etc/profile' > /root/.bashrc && \
    echo 'source /etc/profile' > /root/.bash_profile && \
    echo 'export FIXUID=$(id -u) \n\
          export FIXGID=$(id -g)' > /etc/profile.d/fixuid.sh && \
    chown ci:ci /srv

ENV GIT_LFS_VERSION 2.11.0
ENV GIT_LFS_HASH 46508eb932c2ec0003a940f179246708d4ddc2fec439dcacbf20ff9e98b957c9
RUN mkdir -p /tmp/build && cd /tmp/build \
  && curl -sSL -o git-lfs.tgz https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-amd64-v${GIT_LFS_VERSION}.tar.gz \
  && echo "${GIT_LFS_HASH}  git-lfs.tgz" | sha256sum -c - \
  && tar -xzf git-lfs.tgz \
  && cp git-lfs /usr/local/bin/ \
  && cd / && rm -rf /tmp/build \
  && git lfs install --system

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
      unzip awscliv2.zip && \
      ./aws/install && \
      rm awscliv2.zip

USER ci

ENV BUNDLER_VERSION 2.1.4
RUN gem install bundler -v ${BUNDLER_VERSION} --force --no-document

WORKDIR /srv
CMD ["/bin/bash"]
