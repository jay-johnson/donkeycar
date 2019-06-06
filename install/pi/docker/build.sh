#!/bin/bash

maintainer=jayjohnson
imagename=arm32v7-base

tag=$(cat ../../../setup.py | grep "version=" | sed -e 's/"/ /g' | awk '{print $2}')

echo ""
echo "--------------------------------------------------------"
echo "Building new base image: ${maintainer}/${imagename}"
base_image="$maintainer/$imagename"
docker build -f ./base/Dockerfile --rm -t ${base_image} .
last_status=$?
if [[ "${last_status}" != "0" ]]; then
    echo ""
    echo "failed to build base image: ${base_image}"
    echo "docker build -f ./repo/Dockerfile --rm -t ${base_image} ."
    echo ""
    exit 1
fi

imagename=arm32v7-python37-venv
repo_image="$maintainer/$imagename"
docker build -f ./python3.7/Dockerfile --rm -t ${repo_image} .
last_status=$?
if [[ "${last_status}" != "0" ]]; then
    echo ""
    echo "failed to build python image: ${repo_image}"
    echo "docker build -f ./python3.7/Dockerfile --rm -t ${repo_image} ."
    echo ""
    exit 1
fi

imagename=arm32v7-python37-repo-base
repo_image="$maintainer/$imagename"
docker build -f ./repo/Dockerfile --rm -t ${repo_image} .
last_status=$?
if [[ "${last_status}" != "0" ]]; then
    echo ""
    echo "failed to build repo image: ${repo_image}"
    echo "docker build -f ./repo/Dockerfile --rm -t ${repo_image} ."
    echo ""
    exit 1
fi
if [[ "${last_status}" == "0" ]]; then
    echo ""
    if [[ "${tag}" != "" ]]; then
        image_csum=$(docker images | grep "${maintainer}/${imagename} " | grep latest | awk '{print $3}')
        if [[ "${image_csum}" != "" ]]; then
            docker tag $image_csum $maintainer/$imagename:$tag
            last_status=$?
            if [[ "${last_status}" != "0" ]]; then
                echo "Failed to tag image(${imagename}) with Tag(${tag})"
                echo ""
                exit 1
            else
                echo "Build Successful Tagged Image(${imagename}) with Tag(${tag})"
            fi

            echo ""
            exit 0
        else
            echo ""
            echo "Build failed to find latest image(${imagename}) with Tag(${tag})"
            echo ""
            exit 1
        fi
    else
        echo "Build Successful"
        echo ""
        exit 0
    fi
    echo ""
else
    echo ""
    echo "Build failed with exit code: ${last_status}"
    echo ""
    exit 1
fi

exit 0
