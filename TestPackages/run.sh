#!/usr/bin/env bash

for _os in centos; do
    DOCKERFILE=./Dockerfile.${_os}
    docker build \
        --no-cache \
        --tag moose-package:${_os}
        --build-arg HTTP_PROXY=proxy.ncbs.res.in:3128 \
        --build-arg HTTPS_PROXY=proxy.ncbs.res.in:3128 \
        -f $DOCKERFILE
done
