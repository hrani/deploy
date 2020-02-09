# This docker image is based on bhallalab/manylinux2010 which is
# ./hub.docker.com/wheel/Makefile
FROM bhallalab/manylinux2010:latest
MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>
ARG PYMOOSE_PYPI_PASSWORD
ENV PYMOOSE_PYPI_PASSWORD=${PYMOOSE_PYPI_PASSWORD}
WORKDIR /root
COPY ./BRANCH .
COPY ./build_wheels_linux.sh .
RUN ./build_wheels_linux.sh
