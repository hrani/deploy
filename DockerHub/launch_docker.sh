#!/usr/bin/env bash

docker run -ti --rm -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix bhallalab/moose:latest
