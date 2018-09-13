#!/usr/bin/env bash

for _os in centos; do
    DOCKERFILE=./Dockerfile.${_os}
    docker build \
        --tag moose-package:${_os} \
        --build-arg http_proxy="http://proxy.ncbs.res.in:3128/" \
        --build-arg https_proxy="http://proxy.ncbs.res.in:3128/" \
        -f $DOCKERFILE .
done
