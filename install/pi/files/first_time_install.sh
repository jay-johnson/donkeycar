#!/bin/bash

export DCPATH=/opt/dc
if [[ -e ${DCPATH}/install/pi/files/bash_colors.sh ]]; then
    source ${DCPATH}/install/pi/files/bash_colors.sh
fi

anmt "letting services start"
date +"%Y-%m-%d %H:%M:%S"
sleep 30

python_version="3.7"

anmt "getting updates"
date +"%Y-%m-%d %H:%M:%S"
sudo apt-get update -y \
    -o "Dpkg::Options::=--force-confdef" \
    -o "Dpkg::Options::=--force-confold" >> /var/log/sdupdate.log 2>&1

if [[ -e /opt/upgrade-packages ]]; then
    anmt "starting upgrade"
    date +"%Y-%m-%d %H:%M:%S"
    # from blog: https://raymii.org/s/blog/Raspberry_Pi_Raspbian_Unattended_Upgrade_Jessie_to_Testing.html
    sudo DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade >> /var/log/sdupdate.log 2>&1
    if [[ "$?" != "0" ]]; then
        err "failed to upgrade before installing initial packages"
        exit 1
    else
        # Remove no longer needed packages
        anmt "removing stale packages now that the upgrade is done"
        sudo DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" autoremove --purge >> /var/log/sdupdate.log 2>&1
        date +"%Y-%m-%d %H:%M:%S"
        good "upgrade packages - complete"
    fi
    sudo rm -f /opt/upgrade-packages
else
    anmt "no package upgrade scheduled: /opt/upgrade-packages"
fi

if [[ -e /opt/install-packages ]]; then
    anmt "detected install packages request"
    install_packages=$(sudo cat /opt/install-packages)
    anmt "installing packages: ${install_packages}"
    date +"%Y-%m-%d %H:%M:%S"
    sudo apt-get install -y \
        -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" \
        ${install_packages} >> /var/log/sdinstall.log 2>&1

    if [[ "$?" != "0" ]]; then
        err "failed to initial packages: ${install_packages}"
        exit 1
    else
        date +"%Y-%m-%d %H:%M:%S"
        good "install packages - complete"
    fi

    sudo rm -f /opt/install-packages
else
    anmt "no package install scheduled: /opt/install-packages"
fi

if [[ ! -e /opt/stay-on-python35 ]] && [[ -e /opt/use-python37 ]] && [[ ! -e /usr/local/bin/python${python_version} ]] && [[ ! -e /usr/local/bin/pip${python_version} ]]; then
    anmt "installing python ${python_version}.3 from source from gist: https://gist.github.com/SeppPenner/6a5a30ebc8f79936fa136c524417761d#gistcomment-2920338"
    date +"%Y-%m-%d %H:%M:%S"
    sudo apt-get update -y
    anmt "installing build packages"
    sudo apt-get install build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev -y
    anmt "downloading python ${python_version}.3 source: https://www.python.org/ftp/python/${python_version}.3/Python-${python_version}.3.tar.xz"
    wget https://www.python.org/ftp/python/${python_version}.3/Python-${python_version}.3.tar.xz
    pushd /opt >> /dev/null 2>&1
    tar xf Python-${python_version}.3.tar.xz
    cd Python-${python_version}.3
    ./configure
    anmt "building python ${python_version}3"
    make -j 4
    sudo make -j4 altinstall
    cd ..
    anmt "removing /opt/Python-${python_version}.3"
    sudo rm -r Python-${python_version}.3
    anmt "removing /opt/Python-${python_version}.3.tar.xz"
    rm Python-${python_version}.3.tar.xz
    popd >> /dev/null 2>&1
    anmt "removing old packages"
    sudo apt-get autoremove -y
    anmt "cleaning"
    sudo apt-get clean

    if [[ -e /usr/bin/python3 ]] && [[ -e /usr/local/bin/python${python_version} ]]; then
        sudo rm -f /usr/bin/python3
    fi
    if [[ -e /usr/local/bin/python${python_version} ]]; then
        sudo ln -s /usr/local/bin/python${python_version} /usr/bin/python3

        if [[ "$(which python | wc -l)" == "0" ]]; then
            sudo ln -s /usr/local/bin/python${python_version} /usr/bin/python
        fi
    else
        err "failed to find python ${python_version} at: /usr/bin/python${python_version}"
    fi
    if [[ -e /usr/bin/python3m ]] && [[ -e /usr/local/bin/python${python_version}m ]]; then
        sudo rm -f /usr/bin/python3m
    fi
    if [[ -e /usr/local/bin/python${python_version}m ]]; then
        sudo ln -s /usr/local/bin/python${python_version}m /usr/bin/python3m
    else
        err "failed to find python ${python_version}m at: /usr/bin/python${python_version}m"
    fi
    if [[ -e /usr/bin/pip ]] && [[ -e /usr/local/bin/pip${python_version} ]]; then
        sudo mv /usr/bin/pip /usr/bin/backup-pip
    fi
    if [[ -e /usr/bin/pip3 ]] && [[ -e /usr/local/bin/pip${python_version} ]]; then
        sudo mv /usr/bin/pip3 /usr/bin/backup-pip3-3.5
    fi
    if [[ -e /usr/local/bin/pip${python_version} ]]; then
        sudo ln -s /usr/local/bin/pip${python_version} /usr/bin/pip
        sudo ln -s /usr/local/bin/pip${python_version} /usr/bin/pip3
    else
        err "failed to find pip${python_version} at: /usr/bin/pip${python_version}"
    fi

    # lsb_release module fix:
    # https://askubuntu.com/questions/965043/no-module-named-lsb-release-after-install-python-3-6-3-from-source
    if [[ -e /usr/local/lib/python${python_version}/site-packages/lsb_release.py ]]; then
        anmt "installing lsb_release fix: sudo ln -s /usr/share/pyshared/lsb_release.py /usr/local/lib/python${python_version}/site-packages/lsb_release.py"
        sudo ln -s /usr/share/pyshared/lsb_release.py /usr/local/lib/python${python_version}/site-packages/lsb_release.py
        ls -l /usr/local/lib/python${python_version}/site-packages/lsb_release.py
    fi

    date +"%Y-%m-%d %H:%M:%S"
    good "done - installing python ${python_version}.3 from source from gist: https://gist.github.com/SeppPenner/6a5a30ebc8f79936fa136c524417761d#gistcomment-2920338"
fi

if [[ -e ${DCPATH}/install/pi/files/rebuild_pip.sh ]]; then
    anmt "rebuilding pip in ${DCPATH} with: ${DCPATH}/install/pi/files/rebuild_pip.sh"
    chmod 777 ${DCPATH}/install/pi/files/rebuild_pip.sh
    ${DCPATH}/install/pi/files/rebuild_pip.sh >> /var/log/sdrepo.log 2>&1
fi

# https://docs.fluentbit.io/manual/getting_started
if [[ -e ${DCPATH}/install/pi/files/fluent-bit-install.sh ]]; then
    anmt "installing fluent bit with: ${DCPATH}/install/pi/files/fluent-bit-install.sh"
    chmod 777 ${DCPATH}/install/pi/files/fluent-bit-install.sh
    ${DCPATH}/install/pi/files/fluent-bit-install.sh >> /var/log/sdinstall.log 2>&1
fi

test_exists=$(which docker | wc -l)
if [[ "${test_exists}" == "0" ]]; then
    if [[ -e ${DCPATH}/install/pi/files/docker-install.sh ]]; then
        anmt "installing docker: ${DCPATH}/install/pi/files/docker-install.sh"
        chmod 777 ${DCPATH}/install/pi/files/docker-install.sh
        ${DCPATH}/install/pi/files/docker-install.sh >> /var/log/sdinstall.log 2>&1
    fi
fi

date +"%Y-%m-%d %H:%M:%S"
good "done"

EXITVALUE=0
exit $EXITVALUE
