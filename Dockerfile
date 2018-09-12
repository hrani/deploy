FROM quay.io/pypa/manylinux1_x86_64

ARG PYPI_PASSWORD
ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""


MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>
ENV PATH=/usr/local/bin:$PATH
RUN yum update
RUN yum install -y cmake28 && ln -sf /usr/bin/cmake28 /usr/bin/cmake
RUN yum install -y wget  
RUN curl -sL -O https://github.com/BhallaLab/deploy/archive/master.tar.gz 
RUN ls -la *.gz
RUN tar xvf master.tar.gz
RUN cd deploy-master && ./build_wheels_linux.sh 
RUN echo "pass $PYPI_PASSWORD"
RUN cd deploy-master && ./test_and_upload.sh "$PYPI_PASSWORD"
