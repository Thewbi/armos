## Docker

To develop on Linux with qemu on any Host-OS (Linux, Windows, Mac) Docker is used.
This chapter explains how to setup and use Docker.

This course uses docker to run a Linux on any Host system. Linux is required because
the ARM toolchain on Linux is able to compile freestanding code which means code
that uses no libraries or other dependencies and can be run on the hardware.
The Linux that is run inside Docker will be used to compile the code of your custom OS.

Running a Linux on Windows or Mac is surprisingly easy using Docker. Docker is a
infrastructure that makes the concept of Infrastructure as Code available to everyone.
People write Dockerfiles that contain instructions on how to set up an operating system.
You can build on the work on others to derive your own Dockerfile from an existing
Dockerfile and add features to the OS.

Once you have your environment described as a Dockerfile (Infrastructure as Code) you
let Docker execute the Dockerfile. It will create a container. You can start one or more
of those containers on your host OS. The Containers have individual file systems and can
mount folders from the host OS. The containers can connect to other infrastructure via
TCP/IP and other protocols as they are first class Operating Systems inside.

Ultimately you can open a command line into the OS inside the running Docker container and
you can execute Linux commands. This course places the source code inside a folder on the
Host OS where you will edit those files. Then the Docker Container mounts that folder and
compiles the code inside itself on the Linux using the ARM toolchain. This yields a kernel
image which you can then transfer on a SD Card or run in an emulator such as qemu.

### Installing Docker on Linux

TODO

### Installing Docker on Windows

Download and install Docker Desktop from https://www.docker.com/

### Installing Docker on MacOS

Download and install Docker Desktop from https://www.docker.com/
