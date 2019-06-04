#!/bin/bash

export DCPATH=/opt/dc
if [[ -e ${DCPATH}/install/pi/files/bash_colors.sh ]]; then
    source ${DCPATH}/install/pi/files/bash_colors.sh
fi

anmt "Installing Fluent Bit: https://fluentbit.io/documentation/0.8/installation/raspberry_pi.html"
date +"%Y-%m-%d %H:%M:%S"

# instructions from:
# https://fluentbit.io/documentation/0.8/installation/raspberry_pi.html

test_exists=$(cat /etc/apt/sources.list | grep fluentbit | wc -l)
if [[ "${test_exists}" != "0" ]]; then
    good "already have fluentbit in the sources"
else
    anmt "installing fluentbit key"
    wget -qO - http://packages.fluentbit.io/fluentbit.key | sudo apt-key add -

    echo "deb http://packages.fluentbit.io/raspbian jessie main" >> /etc/apt/sources.list
fi

anmt "getting package updates"
apt-get update -y

anmt "installing fluent bit"
apt-get install td-agent-bit -y

anmt "reloading daemon"
systemctl daemon-reload
anmt "enabling fluent bit on reboot"
systemctl td-agent-bit enable
anmt "starting fluent bit"
systemctl td-agent-bit start

good "done - installing fluent bit"

EXITVALUE=0
exit $EXITVALUE
