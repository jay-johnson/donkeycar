#!/bin/bash

if [[ "${DCPATH}" == "" ]]; then
    export DCPATH="."
fi
if [[ -e ${DCPATH}/files/bash_colors.sh ]]; then
    source ${DCPATH}/files/bash_colors.sh
fi

# latest donkey car image id:
latest_image="donkey_2.6.1_pi3.img"
device="/dev/sdf"
if [[ "${DEVICE}" != "" ]]; then
    device="${DEVICE}"
fi
backup_dir="${DCPATH}/backups"
if [[ "${DCBACKUPDIR}" != "" ]]; then
    backup_dir="${DCBACKUPDIR}"
fi

if [[ ! -e ${backup_dir} ]]; then
    mkdir -p -m 777 ${backup_dir}
fi
backup_file="${backup_dir}/${latest_image}"

anmt "creating ${device} backup to: ${backup_file}"
dd if=${device} of=${backup_file} bs=512 status=progress
if [[ "$?" != "0" ]]; then
    err "failed creating ${device} backup to: ${backup_file}"
    exit 1
fi
exit 0
