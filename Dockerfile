FROM quay.io/pypa/manylinux1_x86_64
MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>

# If you are behind proxy,  uncomment the following lines with appropriate
# values. Otherwise comment them out.
ENV http_proxy http://proxy.ncbs.res.in:3128
ENV https_proxy http://proxy.ncbs.res.in:3128
ENV PATH=/usr/local/bin:$PATH

# Attach /tmp to DOCKER /tmp/HOST folder. We save resultant wheels here. Easy to
# upload or test in host post building.
ADD wheelhouse /tmp/WHEELHOUSE

RUN yum update
RUN yum install -y cmake28 && ln -sf /usr/bin/cmake28 /usr/bin/cmake
RUN yum install -y wget  
RUN if [ ! -f /usr/local/lib/libgsl.a ]; then \
    wget --no-check-certificate ftp://ftp.gnu.org/gnu/gsl/gsl-2.4.tar.gz && \
    tar xvf gsl-2.4.tar.gz && cd gsl-2.4 && \
    CFLAGS=-fPIC ./configure --enable-static && make -j4 && \
    make install && cd ..; fi 

RUN rm -rf *.tar.gz
RUN curl -sL -O https://github.com/BhallaLab/pymoose-wheels/archive/master.tar.gz 
RUN ls -la *.gz
RUN tar xvf master.tar.gz
RUN cd pymoose-wheels-master && ./build_wheels_linux.sh /tmp/WHEELHOUSE
