FROM debian:bullseye-slim as build-env
ENV DEBIAN_FRONTEND=noninteractive
ARG TESTS
ARG SOURCE_COMMIT
ARG BUSYBOX_VERSION=1.34.1
ARG SUPERVISOR_VERSION=4.2.4

RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install build-essential curl git python3 python3-pip golang shellcheck

WORKDIR /build/busybox
RUN curl -L -o /tmp/busybox.tar.bz2 https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2 \
    && tar xjvf /tmp/busybox.tar.bz2 --strip-components=1 -C /build/busybox \
    && make defconfig \
    && sed -i -e "s/^CONFIG_FEATURE_SYSLOGD_READ_BUFFER_SIZE=.*/CONFIG_FEATURE_SYSLOGD_READ_BUFFER_SIZE=2048/" .config \
    && make \
    && cp busybox /usr/local/bin/


WORKDIR /build
RUN git clone https://github.com/Yepoleb/python-a2s.git \
    && cd python-a2s \
    && python3 setup.py bdist --format=gztar

# copiar os scripts
COPY defaults /usr/local/etc/corekeeper/

WORKDIR /
RUN rm -rf /usr/local/lib/
RUN tar xzvf /build/python-a2s/dist/python-a2s-*.linux-x86_64.tar.gz
# copiar supervisor conf
RUN echo "${SOURCE_COMMIT:-unknown}" > /usr/local/etc/git-commit.HEAD

# installs i386 libraries
FROM --platform=linux/386 debian:buster-slim as i386-libs
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        libc6-dev \
        libstdc++6 \
        libsdl2-2.0-0 \
        libcurl4 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


FROM debian:bullseye-slim
# ENV DEBIAN_FRONTEND=noninteractive
COPY --from=build-env /usr/local/ /usr/local/
COPY --from=i386-libs /lib/ld-linux.so.2 /lib/ld-linux.so.2
COPY --from=i386-libs /lib/i386-linux-gnu /lib/i386-linux-gnu
COPY --from=i386-libs /usr/lib/i386-linux-gnu /usr/lib/i386-linux-gnu
COPY ./scripts/bootstrap.sh /home/corekeeper/

RUN groupadd -g "${PGID:-0}" -o corekeeper \
    && useradd -g "${PGID:-0}" -u "${PUID:-0}" -o --create-home corekeeper \
    && apt-get update \
    && apt-get -y --no-install-recommends install apt-utils \
    && apt-get -y dist-upgrade \
    && apt-get -y --no-install-recommends install \
        libc6-dev \
        libsdl2-2.0-0 \
        cron \
        curl \
        iproute2 \
        libcurl4 \
        ca-certificates \
        procps \
        locales \
        unzip \
        zip \
        rsync \
        openssh-client \
        jq \
        python3-minimal \
        python3-pkg-resources \
        python3-setuptools \
        libpulse-dev \
        libatomic1 \
        libc6 \
        sudo \
        xvfb \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && rm -f /bin/sh \
    && ln -s /bin/bash /bin/sh \
    && locale-gen \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && usermod -a -G crontab corekeeper \
    && apt-get clean \
    && mkdir -p /var/spool/cron/crontabs /opt/corekeeper /opt/steamcmd /home/corekeeper/.config/unity3d/Pugstorm/Core\ Keeper/DedicatedServer /config /var/run/corekeeper \
    && ln -s /config /home/corekeeper/.config/unity3d/Pugstorm/Core\ Keeper/DedicatedServer/ \
    && ln -s /usr/local/bin/busybox /usr/local/sbin/syslogd \
    && ln -s /usr/local/bin/busybox /usr/local/sbin/mkpasswd \
    && ln -s /usr/local/bin/busybox /usr/local/bin/vi \
    && ln -s /usr/local/bin/busybox /usr/local/bin/patch \
    && ln -s /usr/local/bin/busybox /usr/local/bin/unix2dos \
    && ln -s /usr/local/bin/busybox /usr/local/bin/dos2unix \
    && ln -s /usr/local/bin/busybox /usr/local/bin/makemime \
    && ln -s /usr/local/bin/busybox /usr/local/bin/xxd \
    && ln -s /usr/local/bin/busybox /usr/local/bin/wget \
    && ln -s /usr/local/bin/busybox /usr/local/bin/less \
    && ln -s /usr/local/bin/busybox /usr/local/bin/lsof \
    && ln -s /usr/local/bin/busybox /usr/local/bin/httpd \
    && ln -s /usr/local/bin/busybox /usr/local/bin/ssl_client \
    && ln -s /usr/local/bin/busybox /usr/local/bin/ip \
    && ln -s /usr/local/bin/busybox /usr/local/bin/ipcalc \
    && ln -s /usr/local/bin/busybox /usr/local/bin/ping \
    && ln -s /usr/local/bin/busybox /usr/local/bin/ping6 \
    && ln -s /usr/local/bin/busybox /usr/local/bin/iostat \
    && ln -s /usr/local/bin/busybox /usr/local/bin/setuidgid \
    && ln -s /usr/local/bin/busybox /usr/local/bin/ftpget \
    && ln -s /usr/local/bin/busybox /usr/local/bin/ftpput \
    && ln -s /usr/local/bin/busybox /usr/local/bin/bzip2 \
    && ln -s /usr/local/bin/busybox /usr/local/bin/xz \
    && ln -s /usr/local/bin/busybox /usr/local/bin/pstree \
    && ln -s /usr/local/bin/busybox /usr/local/bin/killall \
    && ln -s /usr/local/bin/busybox /usr/local/bin/bc \
    && curl -L -o /tmp/steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar xzvf /tmp/steamcmd_linux.tar.gz -C /opt/steamcmd/ \
    && chown corekeeper:corekeeper /var/run/corekeeper \
    && chown -R root:root /opt/steamcmd \
    && chmod 755 /opt/steamcmd/steamcmd.sh \
        /opt/steamcmd/linux32/steamcmd \
        /opt/steamcmd/linux32/steamerrorreporter \
        /usr/local/sbin \
    && cd "/opt/steamcmd" \
    && su - corekeeper -c "/opt/steamcmd/steamcmd.sh +login anonymous +quit" \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && date --utc --iso-8601=seconds > /usr/local/etc/build.date



EXPOSE 27010-27015/udp
WORKDIR /
CMD /home/corekeeper/bootstrap.sh

