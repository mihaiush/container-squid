FROM ghcr.io/mihaiush/build:26.803.15 AS build

# renovate: datasource=deb depName=squid-openssl registryUrl=https://deb.debian.org/debian?suite=testing&components=main&binaryArch=amd64
ENV SQUID_VERSION="7.6-2"

RUN \
    export DEBIAN_FRONTEND=noninteractive &&\
    apt-get -q -y update &&\
    apt-get -q -y dist-upgrade --auto-remove &&\
    apt-get -q -y install squid-openssl=$SQUID_VERSION 

RUN \
    ldd_jail build \
        /usr/sbin/squid-openssl /usr/lib/squid /usr/share/squid /usr/share/squid-langpack

RUN \
    mkdir -p /tmp/build/etc &&\
    grep -E '^daemon:' /etc/group >/tmp/build/etc/group &&\
    grep -E '^daemon:' /etc/passwd >/tmp/build/etc/passwd 

FROM scratch

COPY --from=build /tmp/build/ /

VOLUME /tmp

USER 1000

ENTRYPOINT ["/usr/sbin/squid-openssl", "-N"]
