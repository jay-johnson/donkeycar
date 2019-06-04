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

anmt "checking if splunk is enabled"
test_token=$(cat /opt/fluent-bit-includes/config-fluent-bit-in-tcp-out-splunk.yaml | grep REPLACE_SPLUNK_TOKEN | wc -l)
if [[ "${test_token}" == "0" ]]; then
    anmt "including splunk fluent bit file: /opt/fluent-bit-includes/config-fluent-bit-in-tcp-out-splunk.yaml"
    test_exists=$(cat /etc/td-agent-bit/td-agent-bit.conf | grep config-fluent-bit-in-tcp-out-splunk | wc -l)
    if [[ "${test_exists}" == "0" ]]; then
        anmt "installing splunk HEC forwarder with token: echo \"@INCLUDE /opt/fluent-bit-includes/config-fluent-bit-in-tcp-out-splunk.yaml >> /etc/td-agent-bit/td-agent-bit.conf"
        echo "" >> /etc/td-agent-bit/td-agent-bit.conf
        echo "# Adding Splunk HEC Forwarder" >> /etc/td-agent-bit/td-agent-bit.conf
        echo "@INCLUDE /opt/fluent-bit-includes/config-fluent-bit-in-tcp-out-splunk.yaml" >> /etc/td-agent-bit/td-agent-bit.conf
    fi
fi

anmt "reloading daemon"
systemctl daemon-reload
anmt "enabling fluent bit on reboot"
systemctl td-agent-bit enable
anmt "starting fluent bit"
systemctl td-agent-bit start

good "done - installing fluent bit"

EXITVALUE=0
exit $EXITVALUE
