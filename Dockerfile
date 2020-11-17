FROM ubuntu
RUN apt-get update

# install wget
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install wget

# install curl
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install curl

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

# install git
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install git

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

# install The ARM toolchain
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install gcc-aarch64-linux-gnu

# copy the libraries that gcc-none-eabi needs
COPY resources/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1
COPY resources/libc.so.6 /lib64/libc.so.6

# install the gcc arm none eabi toolchain
#WORKDIR gcc-arm-none-eabi
#RUN wget -O gcc-arm-none-eabi.tar.bz2 https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-aarch64-linux.tar.bz2?revision=7166404a-b4f5-4598-ac75-e5f8b90abb09&la=en&hash=01D713C1174E80C856385F5732E9BDC466DB729B
#RUN curl https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-aarch64-linux.tar.bz2?revision=7166404a-b4f5-4598-ac75-e5f8b90abb09&la=en&hash=01D713C1174E80C856385F5732E9BDC466DB729B
#RUN curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-aarch64-linux.tar.bz2 --output gcc-arm-none-eabi-linux.tar.bz2
#RUN tar -xjvf gcc-arm-none-eabi-linux.tar.bz2
#WORKDIR /
