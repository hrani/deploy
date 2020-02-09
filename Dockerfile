FROM bhallalab/manylinux2010:latest
MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>

WORKDIR /root
COPY ./BRANCH .
COPY ./build_wheels_linux.sh .
