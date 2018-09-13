#!/usr/bin/env bash

for _os in debian centon; do
    DOCKERFILE=./Dockerfile.${_os}
    docker build --tag moose-package:${_os} -f $DOCKERFILE .
done
