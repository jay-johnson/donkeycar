#!/bin/bash

repo_dir="/opt/dc"
if [[ "${DCPATH}" != "" ]]; then
    repo_dir="${DCPATH}"
fi
if [[ -e ${repo_dir}/install/pi/files/bash_colors.sh ]]; then
    source ${repo_dir}/install/pi/files/bash_colors.sh
fi
venvpath="/opt/venv"
if [[ "${DCVENVDIR}" != "" ]]; then
    venvpath="${DCVENVDIR}"
fi
user_to_use="pi"
if [[ "${REMOTE_USER}" != "" ]]; then
    user_to_use="${REMOTE_USER}"
fi

if [[ ! -e ${venvpath}/bin/activate ]]; then
    anmt "creating venv: ${venvpath} by ${user_to_use} user with python runtime: $(ls -l /usr/local/bin/python3 | awk '{print $NF}')"
    sudo -u ${user_to_use} /bin/sh -c "virtualenv -p /usr/local/bin/python3.7 ${venvpath}"
    if [[ "$?" != "0" ]]; then
        err "unable to create virtual env for python 3.7 with command:"
        err "sudo -u ${user_to_use} /bin/sh -c \"virtualenv -p /usr/local/bin/python3.7 ${venvpath}\""
        exit 1
    fi
fi

if [[ -e ${venvpath}/bin/activate ]]; then
    anmt "setting permissions for ${user_to_} user on repo: ${repo_dir}"
    sudo chown -R ${user_to_use}:${user_to_use} ${repo_dir}
    sudo chown -R ${user_to_use}:${user_to_use} ${repo_dir}/.git
    anmt "upgrading pip and setuptools: ${venvpath}"
    sudo -u ${user_to_use} /bin/sh -c ". ${venvpath}/bin/activate && pip install --upgrade pip setuptools"

    if [[ -e ${repo_dir} ]]; then
        anmt "checking repo status: ${repo_dir}"
        sudo -u ${user_to_use} /bin/sh -c "cd ${repo_dir} && git status"
        anmt "pulling the latest from $(cat ${repo_dir}/.git/config | grep url | awk '{print $NF}')"
        sudo -u ${user_to_use} /bin/sh -c "cd ${repo_dir} && git pull"
        anmt "installing pips: pip install --upgrade -e ."
        sudo -u ${user_to_use} /bin/sh -c "cd ${repo_dir} && . ${venvpath}/bin/activate && pip install --upgrade -e . && pip list"
    else
        err "did not find repo_dir: ${repo_dir}"
        exit 1
    fi
else
    err "failed to find a valid virtual environment at path: ${venvpath}"
    err "checking permissions on parent directory:"
    ls -l ${venvpath}/.. | grep $(dirname $venvpath)
    if [[ -e ${venvpath} ]]; then
        err "checking permissions on ${venvpath} directory:"
        ls -l $venvpath
    fi
    exit 1
fi

date +"%Y-%m-%d %H:%M:%S"
good "done - rebuild pip: ${repo_dir}"

exit 0
