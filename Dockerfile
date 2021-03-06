FROM ubuntu
RUN apt-get update

# Enabling source repositories and downloading the sources for qemu
#
# backup the original file
RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup
# enable the source repositories by uncommenting the existing lines
RUN sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
# update the cache
RUN apt-get update
# install build dependencies for qemu
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq build-dep qemu

# install git, vim
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install git
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install vim

# download the qemu sources and build qemu with arm support
WORKDIR tmp
RUN git clone https://github.com/qemu/qemu.git
RUN pwd
RUN ls -la
WORKDIR qemu
RUN pwd
RUN ls -la
RUN git checkout v5.0.1
RUN git submodule init
RUN git submodule update --recursive
RUN ./configure --target-list=aarch64-softmmu
RUN make

WORKDIR /

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi libncurses5-dev build-essential bison flex libssl-dev bc

# install The ARM toolchain
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install gcc-aarch64-linux-gnu
