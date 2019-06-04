#!/bin/bash

test_exists=$(which docker | wc -l)
if [[ "${test_exists}" != "0" ]]; then
    echo "docker is already installed"
    exit 0
fi

export DCPATH=/opt/dc
if [[ -e ${DCPATH}/install/pi/files/bash_colors.sh ]]; then
    source ${DCPATH}/install/pi/files/bash_colors.sh
fi
venvpath="/home/pi/env"
if [[ "${DCVENVDIR}" != "" ]]; then
    venvpath="${DCVENVDIR}"
fi

anmt "letting services start"
date +"%Y-%m-%d %H:%M:%S"
sleep 30

anmt "getting updates"
date +"%Y-%m-%d %H:%M:%S"

apt-get update -y \
    -o Dpkg::Options::="--force-confold" --force-yes

anmt "installing initial packages"
date +"%Y-%m-%d %H:%M:%S"

anmt "installing initial packages"
apt-get install -y \
    -o Dpkg::Options::="--force-confold" --force-yes \
    apt-transport-https \
    ca-certificates \
    git \
    net-tools \
    software-properties-common \
    vim

if [[ -e ${DCPATH}/install/pi/files/rebuild_pip.sh ]]; then
    anmt "rebuilding pip in ${DCPATH}"
    date +"installed on: %Y-%m-%d %H:%M:%S" > /tmp/pip-install.log
    anmt "nohup ${DCPATH}/install/pi/files/rebuild_pip.sh >> /tmp/pip-install.log 2>&1 &"
    nohup ${DCPATH}/install/pi/files/rebuild_pip.sh >> /tmp/pip-install.log 2>&1 &
fi

# https://docs.fluentbit.io/manual/getting_started
if [[ -e /opt/dc/install/pi/files/fluent-bit-install.sh ]]; then
    anmt "installing fluent bit: /opt/dc/install/pi/files/fluent-bit-install.sh"
    chmod 777 /opt/dc/install/pi/files/fluent-bit-install.sh
    /opt/dc/install/pi/files/fluent-bit-install.sh 2>&1 /tmp/fluent-bit-install.log
fi

test_exists=$(which docker | wc -l)
if [[ "${test_exists}" == "0" ]]; then
    if [[ -e /opt/dc/install/pi/files/docker-install.sh ]]; then
        anmt "installing docker: /opt/dc/install/pi/files/docker-install.sh"
        chmod 777 /opt/dc/install/pi/files/docker-install.sh
        /opt/dc/install/pi/files/docker-install.sh 2>&1 /tmp/docker-install.log
    fi
fi

date +"%Y-%m-%d %H:%M:%S"
good "done"

EXITVALUE=0
exit $EXITVALUE
