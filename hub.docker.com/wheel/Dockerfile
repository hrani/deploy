# Image for creating wheels.
FROM quay.io/pypa/manylinux2010_x86_64
MAINTAINER Dilawar Singh <dilawars@ncbs.res.in>

RUN yum update && yum install -y git cmake3 vim && yum clean all

WORKDIR /root
RUN git clone https://github.com/dilawar/vim ~/.vim --branch minimal --depth 1
RUN git config --global user.name 'Dilawar Singh' && \
    git config --global user.email 'dilawars@ncbs.res.in' 
RUN cd /tmp && curl -O https://ftp.gnu.org/gnu/gsl/gsl-2.4.tar.gz && \
    tar xvf gsl-2.4.tar.gz && \
    cd gsl-2.4 && \
    CFLAGS=-fPIC ./configure --enable-static && make $MAKEOPTS && \
    make install && \
    cd ~ && rm -rf /tmp/gsl*

