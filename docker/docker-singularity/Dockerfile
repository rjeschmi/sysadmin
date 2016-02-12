FROM centos:7

RUN yum -y install autoconf automake libtool make
RUN mkdir -p /build
WORKDIR /build
RUN curl -LO https://github.com/gmkurtzer/singularity/tarball/master
RUN tar xvzf master
WORKDIR /build/gmkurtzer-singularity-3aa6e2f

RUN ./autogen.sh

RUN make install

