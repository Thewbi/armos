# ARM OS Course

These notes and code are the preparation for a coures that I hopefully can monetize some day on some learning platform.

## Links

https://github.com/bztsrc/raspi3-tutorial
https://github.com/s-matyukevich/raspberry-pi-os

## Development Board

To test the OS on real hardware, the Raspberry PI 3 Model B+ is used.

The specification is contained here: (https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus)

Specification
The Raspberry Pi 3 Model B+ is the final revision in the Raspberry Pi 3 range.

- CPU: Broadcom BCM2837B0, Cortex-A53 (ARMv8) 64-bit SoC @ 1.4GHz with 4 cores (quad-core)
- RAM: 1GB LPDDR2 SDRAM
- Bluetooth: 2.4GHz and 5GHz IEEE 802.11.b/g/n/ac wireless LAN, Bluetooth 4.2, BLE
- Ethernet: Gigabit Ethernet over USB 2.0 (maximum throughput 300 Mbps)
- GPIO: Extended 40-pin GPIO header
- HDMI: Full-size HDMI
- USB: 4 USB 2.0 ports
- CAMERA: CSI camera port for connecting a Raspberry Pi camera
- DSI: DSI display port for connecting a Raspberry Pi touchscreen display
- AUDIO: 4-pole stereo output and composite video port
- SD-SLOT: Micro SD port for loading your operating system and storing data
- POWER: 5V/2.5A DC power input
- PoE: Power-over-Ethernet (PoE) support (requires separate PoE HAT)

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

## Setting up the Development Environment

The goals are to set up a unified, versioned, easily accessible development environment that allows us to develop
and test the OS quickly before moving it to real hardware.

Breaking this top level goal down into more concrete subgoals yields:

1. use Docker to run a linux OS on any host OS to unify the development environment.

2. use a emulator to run the OS on the Broadcom BCM2837B0, Cortex-A53 (ARMv8) 64-bit.

3. Install a toolchain that produces code for the Broadcom BCM2837B0, Cortex-A53 (ARMv8) 64-bit.

4. commit everything into github for versioning and easy access to the code on any Computer.

### Subgoal 1) - Setting up a Docker environment

After reaching this Subgoal you will have a running Ubuntu Linux inside a Docker container that you can open a console to.
The files are put under version control.

First create a new project on github and clone it to your local harddrive.
This is easier than first creating files and cloning the git project later.

```
$ cd /Users/bischowg/dev/osdev
$ git clone https://github.com/Thewbi/armos.git
$ cd armos
```

You can name it whatever you like but you have to replace all occurences for the commands to work.

Install Docker as described in the chapter == Docker ==

Writeing a Dockerfile:

```
FROM ubuntu
RUN apt-get update
```

Save the file using the name 'Dockerfile'. Do not use a file extension.
On Windows, Notepad++ allows you to save the file without extension.

Here, the FROM instruction uses the latest Ubuntu Docker image available at the time of execution and
uses that image as a source for your own Dockerfile. RUN apt-get update tells the Ubuntu package manager
to check for new software from all configured software repositories.

Build the Docker image from the Docker file, give it a name and tag it as the latest version available.

```
$ docker build -t os:latest ./
```

The command docker build has the format:

```
docker build [-t image_name:tag] [Context]
```

The image_name and tag are optional. In software development, when versioning is used it is viable
to fix a name and version of a specific development state, so that should bugs occur later, you
can go to that specific point in development and fix the bug. This is what is called tagging software.

The tag latest will always be your set to your latest release or latest development image.
This allows people to easily retrieve the current version you are working on by convention.

Here the latest tag is set and the name os is used.

Context is the path to a folder which content is copied into the Docker image.
If this folder contains a Dockerfile, docker will execute that Dockerfile.
The Docker build will follow this recipe and construct your Docker image.

The result of the docker build command is visible when you open the Docker Desktop / Dashboard application.
You can also type

```
$ docker images
```

Both result in a list of images that your Docker installation has downloaded and can be started.
That list now contains the os:latest Docker image.

To test the image, start it:

```
$ docker start os
```

In docker desktop, change to the 'Images' section via the navigation on the lefthan side.
Locate the os image and click Run.
Docker Desktop automatically switches to the 'Containers / Apps' Section.
Here one instance of the os container should be contained. Locate that container and
open a shell by clicking the CLI button to the Ubuntu Linux running inside the container.

A shell opens. To test let's output the Ubuntu version:

```
$ uname -a
$ cat /etc/\*release
```

### Mounting folders from host to container

Another feature of Docker that we need is to mount a folder from the host machine into
a running Docker image. This feature is used to edit code on the Host machine using
the editor of your choice (Visual Studio Code, Eclipse, vim, Visual Studio, ...) and
compile the changed files inside the running docker container.

Mouting folders is not done in the Dockerfile because the filesystem differs from
user to user. Instead folders are mounted when starting a container using the -v option.

The command line to start a Docker image and mount a folder on the command line is:

```
$ docker run -v /host/directory:/container/directory -other -options image_name command_to_run
```

In the Docker Dashboard application, two steps are necessary to mount folders into a container

1. Add the host folder to the list of mountable folders
2. Add the parameter to mount the folder

Step 1. is required because Docker Desktop will throw an error if you try to mount a folder
that is not in the list of allowed folders.

The list is editable via Settings > Resources > File Sharing.
Here /Users, /Volumes, /private and /tmp are contained by default.
It is possible to add more folders to the list, by clicking the plus button in the bottom right.

Step 2. actually specifies the host folder and the path in the containered linux where to mount
the host folder. To add this mount information, click on Images > <YOUR_IMAGE> > Run > Unfold 'Optional Settings'

Select the folder via the 'Host Path' input. Select the Container Path via the 'Container Path' input.
The Container Path is the folder inside the containered linux where the host folder will be mounted to.
Then click run to start the container.

The Container is now part of the 'Containers / Apps' list. If you start the Container from the 'Containers / Apps' list
it will automatically contain the configured mount.

you can add parameters before starting an image.
Go to Containers/Apps and locate the container.

## Subgoal 2 - Install the Emulator

Qemu is used to emulate an ARM system.

The qemu version used has to support Cortex-A53 used on the Rasperry Pi 3 Model B+.
There is a qemu version that supports the raspi3 machine model.

Install at least qemu version 2.12 to get Raspberry Pi 3 support.

Checkout the page: https://github.com/qemu/qemu/releases

It tells you, what the latest version is.

The following Dockerfile downloads and builds qemu from source

```
FROM ubuntu
RUN apt-get update

RUN cp /etc/apt/sources.list /etc/apt/sources.list.backup
RUN sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq build-dep qemu

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install git

RUN cd tmp
RUN git clone https://github.com/qemu/qemu.git
RUN pwd
RUN ls -la
RUN cd qemu
RUN pwd
RUN ls -la
RUN git checkout v5.0.1
RUN git submodule init
RUN git submodule update --recursive
RUN ./configure
```

or if you only want ARM support, add the target parameter and specify aarch64-softmmu.
This will speed up the compilation of qemu by hours.
It is strongly recommended to compile for a specific target if you do not want to wait for hours.
At the same time the resulting qemu will only emulate aarch64.

```
RUN ./configure --target-list=aarch64-softmmu

RUN make
```

The qemu executable is located here after the build:

```
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64
```

## Subgoal 3 - install The ARM toolchain

The toolchain is available prepackaged via apt.

```
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install gcc-aarch64-linux-gnu
```

## Subgoal 4 - Commit everything into github for versioning and easy access to the code on any Computer.

If you are not familiar with git, git is a version control system develop by Linus Torvalds primarily for
use with the Linux kernel. It is used in almost all software development projects today. Version control
allows programmers to save their source code in the cloud so no data is lost. It also makes it possible
to precisely track version numbers and which changes where made to which files in which version which is
necessary for bug hunting and releasing version of your software. A distributed version control system
allows several developers to work together on a single code base.

With git, the general idea is that a software repository exists, which is called the remote repository.
Every developer sends their changes to the remote repository. Sending changes is called pushing. Also every
developer gets the latest changes by receiving files from the remote repository which is called pulling.

This remote repository is first copied onto your local harddrive which is called cloning.
Once cloned, changes can be made to the code. Every changed file has to be transfered from
the local repository to the remote repository so other developers and the build system can
work with the improvements. Transfering files back to the remote repository is called pushing.

Git works with branches. The repository is basically a set of branches. Each branch is independant of
other branches and contains source code in the repository. When several branches are alive in a
repository at the same time, different developers can make changes indepdenently to different branches.
Changing between branches is called checkout. You check out a branch and the folders and files on
your local harddrive change to the code that is contained in that branch. At any point in time you
are on exactly one branch. Usually the default branch called master is the current branch after cloning
a remote repository.

Branches are created to work on new features or bugs while the main line branch is still alive
and unchanged. This makes it possible to always release the mainline branch without other unfinished
features interfereing with the release process. Every branch that is created locally has to be pushed
to the remote repository eventually. When a branch is pushed, a remote copy of that branch is created
and your local branch is connected to that remote branch. This connection is called tracking. If you
checkout an existing remote branch, a local clone or copy is created of that remote branch and your
local copy also tracks that remote branch.

The challenge now becomes to merge branches back onto the
mainline branch. This can be challenging because if a file is changed by two branches simulatneously
on the exact same line of code, when bringing those to branches together, who decides how to
merge both changes together?

Git will automatically merge changes in different spots in the same file
because technically different lines do not conflict with each other. If git however finds that the same line
was changed during merging, it will not automatically merge but it will signal a conflict which is
to be manually resolved by the two developers that have changed the line! This can result in a lot of
blood, tiers and anger...

Not only can there be conflicts when merging two different branches together. It is also possible
that you work on the same branch that other developers also have checked out. That means changes can be
pushed to the same remote branch by different developers simultaneously. This in turn opens up the
situation where changes are present in the remote branch that you do not have on your local copy
while you have made local changes.

When loading data to your local copy, which is called pulling, you can get conflicts if you have
locally changed a file on a specific line that some other developer has also changed and pushed their
changes.

Now that some of the most relevant git concepts are talked about, there is one aspect that will make
everything easier for the beginner. This fact is that for following this course, you are most likely
the sole programmer in your OS project and hence conflicts are minimized and you do not have to care
about merging and conflict solving. The only thing you care about is make sure your code is save and
does not get lost.

To transfer changed files, the following steps are necessary

1. Pull from the remote branch to find out if someone changed the files in the meantime
2. Fix conflicts
3. Stage all changed files using git add
4. Commit the staged files
5. Push the commit

When files are changed, git will recognize the changed files.
The git status command lists all changed or added files.

To work with those changed or added files, these files have to go into the staging area first.

Git will only transfer commits. A commit is created from the current staging area.
Files that are not part of the staging area will not be part of a commit even if they are changed or added.
To add a file to the staging area, the git add command is used.

```
git add *
```

Once a subset or all files are staged, the staging area has to be commited.
When a commit is performed, git automatically stores the entire staging area in the commit.
To perform a commit, the command git commit is used. You have to specify a comment.

```
git commit -m "comment goes here"
```

Once you have a local commit, you can transfer that local commit to the remote branch. This is done via the
git push command.

```
git push
```

Because staging and commiting are separate from one another. You can first commit several times before transfering
all commits. Git allows you to work offline by first commiting locally several times. Then, when you to get back
your internet connection, you can commit all your changes to the remote repository.

How to split and package changes into commits is a highly individual preference. Best practice is to never commit
anything to the remote repository that does not run. A eye-opening read about how to be succesfull with
software development in a team is the talk by John Romero. https://www.youtube.com/watch?v=KFziBfvAFnM
He knows what he is talking about.

Let's commit the current development environment to github.

```
$ cd /Users/bischowg/dev/osdev/os
$ git add *
$ git commit -m "initial commit"
$ git push
```

If you already created a folder and files before cloning with git, git will complain.
To clone into a existing folder:

```
$ git init
$ git remote add origin https://github.com/Thewbi/armos.git
$ git pull origin main
$ git push --set-upstream origin main
$ git add *
$ git commit -m "initial commit"
$ git push
```

As a last part, we add a .dockerignore and add the entry README.md to it.
The .dockerignore file is similar to the .gitignore file in that it tells
docker which files not to copy from the current directory into the docker image.

As the README.md is part of the git repository but does not actualy belong to
the docker image, it is ignored. If you have other files that should not go
into the Docker image, you can add them to the .dockerignore file.

The Dockerfile itself never is copied into the Docker image.

First check which files have been modified or added according to git

```
$ git status
```

Perform a git add for all modified or created files that you want to be part of the version controlled repository

```
$ git add <filename>
```

You can also use the wildcard \* to add all modified or created files.

```
$ git add \*
```

If you want to ignore files, add them to .gitignore

Commit the added (= staged) files

```
$ git commit -m "<Your_Comment_Goes_Here>"
```

Finally push the changes from your local into the remote repository

```
$ git push
```

Check on the github homepage if the changes made it to the remote repository.

## Running the kernel on qemu

https://github.com/bztsrc/raspi3-tutorial/blob/master/README.md

```
qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio
```

As a Test:
https://raspberrypi.stackexchange.com/questions/34733/how-to-do-qemu-emulation-for-bare-metal-raspberry-pi-images/85135#85135

cd /temp

# Get source.

git clone https://github.com/bztsrc/raspi3-tutorial
cd raspi3-tutorial
git checkout efdae4e4b23c5b0eb96292f2384dfc8b5bc87538

# Setup to use the host precompiled cross compiler.

# https://github.com/bztsrc/raspi3-tutorial/issues/30

```
apt-get install gcc-aarch64-linux-gnu
find . -name Makefile | xargs sed -i 's/aarch64-elf-/aarch64-linux-gnu-/'
```

# Compile and run stuff.

cd 05_uart0
make
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img -serial stdio

Q: Unable to init server: Could not connect: Connection refused
gtk initialization failed
A: Use -nographic

Q: EMU 5.0.1 monitor - type 'help' for more information
(qemu) qemu-system-aarch64: -serial stdio: cannot use stdio by multiple character devices
qemu-system-aarch64: -serial stdio: could not connect serial device to character backend 'stdio'
A: Start without -serial stdio
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img

## How can I terminate qemu?

Use ^a x
This means, press and hold Ctrl then press a, release Ctrl and a, then press x

## Debugging

https://bertrand.tognoli.fr/todo/work/MyOwnKernel.html

## USB Stack

You need the USB stack not only for USB devices but also for the ethernet connection,
because the ethernet connection is implemented as a hardware chip that actually converts USB to Ethernet.
https://raspberrypi.stackexchange.com/questions/13241/bare-metal-programming-how-to-access-ethernet-hw-interface

## Drivers

### Driver for External Clock

### Driver for Gyro Sensor

## Networked boot

https://metebalci.com/blog/bare-metal-rpi3-network-boot/

## Networking

https://raspberrypi.stackexchange.com/questions/13241/bare-metal-programming-how-to-access-ethernet-hw-interface

https://ownyourbits.com/2017/02/06/raspbian-on-qemu-with-network-access/

### TCP/IP

## Running the OS on Raspberry PI 3 B+

## Running the OS on BeagleBone Black
