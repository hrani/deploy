FROM bhallalab/manylinux2010:latest
MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>

ARG PYPI_PASSWORD

WORKDIR /root
COPY ./build_wheels_linux.sh .
COPY ./test_and_upload.sh .
COPY ./BRANCH .
RUN ./build_wheels_linux.sh  && ./test_and_upload.sh "$PYPI_PASSWORD"
