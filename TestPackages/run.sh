#!/usr/bin/env bash
set -e

for _os in debian centos; do
    DOCKERFILE=./Dockerfile.${_os}
    docker build --tag moose-package:${_os} -f $DOCKERFILE .
done
