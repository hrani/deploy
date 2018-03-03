FROM quay.io/pypa/manylinux1_x86_64
MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>

# If you are behind proxy,  uncomment the following lines with appropriate
# values. Otherwise comment them out.
ENV http_proxy http://proxy.ncbs.res.in:3128
ENV https_proxy http://proxy.ncbs.res.in:3128

ENV PATH=/usr/local/bin:$PATH

RUN yum update
RUN yum install -y cmake28 && ln -sf /usr/bin/cmake28 /usr/bin/cmake
RUN yum install -y wget  
RUN ./build_wheels_linux.sh && ./test_and_upload.sh $PYPI_PASSWORD
