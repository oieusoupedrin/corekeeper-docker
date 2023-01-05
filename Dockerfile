
FROM debian:bullseye-slim as build-env
# ENV DEBIAN_FRONTEND=noninteractive
ARG SUPERVISOR_VERSION=4.2.4
ADD . .
RUN apt-get update
# RUN apt-get -y install apt-utils
# RUN apt-get -y install build-essential curl git python3 python3-pip golang shellcheck

# WORKDIR /build
# RUN git clone https://github.com/Yepoleb/python-a2s.git \
#     && cd python-a2s \
#     && python3 setup.py bdist --format=gztar

# WORKDIR /build/supervisor
# RUN curl -L -o /tmp/supervisor.tar.gz https://github.com/Supervisor/supervisor/archive/${SUPERVISOR_VERSION}.tar.gz \
#     && tar xzvf /tmp/supervisor.tar.gz --strip-components=1 -C /build/supervisor \
#     && python3 setup.py bdist --format=gztar

RUN cat README.md
COPY README.md /build/
RUN cat /build/README.md
RUN echo "teste"
# FROM ubuntu:latest

# LABEL maintainer="eusouoPedrin"
# ARG PUID=1000

# ENV USER steam

# RUN apt-get update \
#     && apt-get -y install software-properties-common

# RUN apt-get -y install apt-utils

# RUN dpkg --add-architecture i386 \
#     && apt-get update \
#     && apt-get install -y --no-install-recommends --no-install-suggests \
#         apt-utils \
#         sudo \
#         ufw \
#         wget \
#         vim \
#         curl 

# # cria o user com a senha gerada com
# # perl -e 'print crypt("password", "salt"), "\n"'

# RUN useradd -u "${PUID}" -m -p "sa3tHJ3/KuYvI" "${USER}" \
#     && usermod -aG sudo steam \
#     && sudo -u steam -s \
#     && cd /home/steam 


# USER steam

# RUN mkdir -p /home/steam/.config/unity3d/Pugstorm/Core\ Keeper/DedicatedServer/ \
#     && mkdir /home/steam/Steam/steamapps/common/Core\ Keeper\ Dedicated\ Server/

# RUN echo "password" | sudo -S apt-get update \
#     && echo steam steam/question select "I AGREE" | sudo debconf-set-selections  \
#     && echo steam steam/license note '' | sudo debconf-set-selections\
#     && sudo apt-get -y install steamcmd \
#         lib32gcc-s1 \
#     && sudo ln -s /usr/games/steamcmd /home/steam/steamcmd \
#     && cd /home/steam \
#     && ./steamcmd +login anonymous +app_update 1007 +app_update 1963720 +quit 




# EXPOSE 27010/udp
# EXPOSE 27011/udp

# CMD /bin/bash