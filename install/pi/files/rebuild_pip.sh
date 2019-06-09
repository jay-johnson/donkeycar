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
repo="https://github.com/jay-johnson/donkeycar.git"
if [[ "${DCREPO}" != "" ]]; then
    repo="${DCREPO}"
fi
branch="d1"
if [[ "${DCBRANCH}" != "" ]]; then
    branch="${DCBRANCH}"
fi

if [[ ! -e ${venvpath}/bin/activate ]]; then
    anmt "creating venv: ${venvpath} python runtime: $(ls -l /usr/local/bin/python3 | awk '{print $NF}')"
    virtualenv -p /usr/local/bin/python3.7 ${venvpath}
    if [[ "$?" != "0" ]]; then
        err "unable to create virtual env for python 3.7 with command:"
        virtualenv -p /usr/local/bin/python3.7 ${venvpath}
        exit 1
    fi
fi

if [[ -e ${venvpath}/bin/activate ]]; then
    anmt "activating venv: ${venvpath}"
    source ${venvpath}/bin/activate

    anmt "upgrading pip and setuptools:"
    pip install --upgrade pip setuptools

    if [[ ! -e ${repo_dir} ]]; then
        anmt "cloning ${repo}"
        git clone ${repo} ${repo_dir}
        if [[ "$?" != "0" ]]; then
            err "failed to clone repo: ${repo} ${repo_dir}"
            exit 1
        fi
        cd ${repo_dir}
        echo "${repo} in ${repo_dir} checking out branch: ${branch}"
        git checkout ${branch}
        if [[ "$?" != "0" ]]; then
            err "failed to checkout ${repo} branch: ${branch} in ${repo_dir}"
            ls -l ${repo_dir}/*
            exit 1
        fi
    fi

    if [[ ! -e ${repo_dir} ]]; then
        err "failed to find ${repo_dir} after clone attempt"
        err "git clone ${repo} ${repo_dir}"
        if [[ -e ~/.ssh/id_rsa.pub ]]; then
            echo ""
            echo "please confirm this ssh key has access to pull this repo: ${repo}"
            cat ~/.ssh/id_rsa.pub
            echo ""
        else
            echo ""
            echo "did not find a public ssh key ~/.ssh/id_rsa.pub - please confirm this user has a private ssh key that can clone the repo: ${repo}"
            echo ""
        fi
        exit 1
    fi

    if [[ -e ${repo_dir} ]]; then
        pushd ${repo_dir} >> /dev/null 2>&1
        anmt "checking repo status: ${repo_dir}"
        git status
        anmt "pulling the latest from $(cat ${repo_dir}/.git/config | grep url | awk '{print $NF}')"
        git pull
        anmt "installing pips: pip install --upgrade -e ."
        pip install --upgrade -e .
        popd >> /dev/null 2>&1
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
