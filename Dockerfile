#
# Quick and easy zcash testnet node
#

# todo: use alpine linux to keep our images smaller
FROM baseboxorg/library-debian:jessie

# create user
RUN useradd -ms /bin/bash zcash
ENV HOME=/home/zcash
ENV PATH="/home/zcash/bin:${PATH}"
WORKDIR /home/zcash

# install deps
RUN docker-apt-install \
    apt-transport-https \
    ca-certificates \
    wget

# install zcash from their apt source. https://github.com/zcash/zcash/wiki/Debian-binary-packages
RUN wget -qO - https://apt.z.cash/zcash.asc | apt-key add - \
 && echo "deb https://apt.z.cash/ jessie main" >/etc/apt/sources.list.d/zcash.list \
 && docker-apt-install zcash

#wget https://s3-us-west-1.amazonaws.com/zcash.dl.mercerweiss.com/zcash-1.0.1-amd64.deb
#sudo dpkg -i zcash-1.0.1-amd64.deb
#apt
# setup data volumes
RUN mkdir -p ~/.zcash ~/.zcash-params
VOLUME /home/zcash/.zcash /home/zcash/.zcash-params

ADD ./start-zcashd.sh /start-zcashd.sh
USER zcash

# Metadata params
ARG BUILD_DATE
ARG VERSION
ARG VCS_URL
ARG VCS_REF
# Metadata
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Zcash" \
      org.label-schema.description="Running Zcash in docker container" \
      org.label-schema.url="https://z.cash/" \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor="AnyBucket" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      com.microscaling.docker.dockerfile="/Dockerfile"


CMD ["sh", "/start-zcashd.sh"]

HEALTHCHECK --interval=5m --timeout=3s \
    CMD zcash-cli getinfo || exit 1


EXPOSE 8233
