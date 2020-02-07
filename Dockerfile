FROM quay.io/pypa/manylinux2010_x86_64

ARG PYPI_PASSWORD

MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>
RUN yum update -y
RUN yum install -y cmake3 wget vim sudo && yum clean all
ENV PATH=/usr/local/bin:$PATH
WORKDIR /root
COPY . deploy
RUN cd deploy && ./build_wheels_linux.sh 
RUN echo "pass $PYPI_PASSWORD"
RUN cd deploy && ./test_and_upload.sh "$PYPI_PASSWORD"
