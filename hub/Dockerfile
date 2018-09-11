FROM ubuntu:16.04
MAINTAINER Dilawar Singh <dilawar.s.rajput@gmail.com>

# If you are behind proxy,  uncomment the following lines with appropriate
# values. Otherwise comment them out.
ENV http_proxy http://proxy.ncbs.res.in:3128
ENV https_proxy http://proxy.ncbs.res.in:3128

ENV PATH=/usr/local/bin:$PATH

RUN apt update && apt install wget -yy
RUN wget -nv https://download.opensuse.org/repositories/home:moose/xUbuntu_16.04/Release.key -O Release.key
RUN apt-key add - < Release.key && rm -f Release.key
RUN sh -c "echo 'deb http://download.opensuse.org/repositories/home:/moose/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/home:moose.list"
RUN apt-get update
RUN apt install python-numpy python-matplotlib python-networkx -yy
RUN apt install python-networkx graphviz -yy
RUN apt install moose -yy --allow-unauthenticated
RUN python -c 'import moose;print(moose.__file__);print(moose.__version__)'
