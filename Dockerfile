FROM ubuntu:latest

LABEL maintainer="eusouoPedrin"
ARG PUID=1000

ENV USER steam

RUN apt-get update \
    && apt-get -y install software-properties-common

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        apt-utils \
        sudo \
        ufw \
        wget \
        vim \
        curl

# cria o user com a senha gerada com
# perl -e 'print crypt("password", "salt"), "\n"'

RUN useradd -u "${PUID}" -m -p "sa3tHJ3/KuYvI" "${USER}" \
    && usermod -aG sudo steam \
    && sudo -u steam -s \
    && cd /home/steam 


USER steam

RUN mkdir -p /home/steam/.config/unity3d/Pugstorm/Core\ Keeper/DedicatedServer/ \
    && mkdir /home/steam/Steam/steamapps/common/Core\ Keeper\ Dedicated\ Server/

RUN echo "password" | sudo -S apt-get update \
    && echo steam steam/question select "I AGREE" | sudo debconf-set-selections  \
    && echo steam steam/license note '' | sudo debconf-set-selections\
    && sudo apt-get -y install steamcmd \
        lib32gcc-s1 \
    && sudo ln -s /usr/games/steamcmd /home/steam/steamcmd \
    && cd /home/steam \
    && ./steamcmd +login anonymous +app_update 1007 +app_update 1963720 +quit 




EXPOSE 27010/udp
EXPOSE 27011/udp

CMD /bin/bash