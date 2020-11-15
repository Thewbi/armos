# Baremetal Assembler

This section is heavily inspired by https://github.com/bztsrc/raspi3-tutorial/blob/master/01_bareminimum
You shoud check out this very good write first.

## Introduction

To make a C programm run, you need a .text and a .bss section.
Also C needs a stack.

This first assembly version does not add those features and only runs assembly instructions.

The programming workflow is as follows:

1. Writing Code - Using a text editor, code is written to text files.
2. Compiling - A compiler compiles the code to object files.
3. Linking - A linker links all object files into a executable (elf).
4. Kernel Image Extraction - A kernel image is extracted from the elf.
5. Running - The kernel image is copied onto a SD Card or run in an emulator.
6. Writing a Makefile - For convenience, automate the process using make

### Step 1 - Writing Code

https://azeria-labs.com/writing-arm-assembly-part-1/
https://www.mikrocontroller.net/articles/ARM-ASM-Tutorial

The assembly instructions used are:

wfe - wait for event (https://www.keil.com/support/man/docs/armasm/armasm_dom1361289926047.htm)

b - branch (https://www.keil.com/support/man/docs/armasm/armasm_dom1361289863797.htm)
The B instruction causes a branch to label.

The code used is, save it as start.S:

```
.section ".text"

.global _start

_start:
main:  wfe
    b       main
```

_.section ".text"_ creates a section that will contain the code below.
This section is then later read by the linker and relocated to a correct address.

_.global \_start_ defines the \_start: label as the entry point of the application.

```
main:  wfe
    b       main
```

is an endless loop that executes the wfe instruction. It is just used as a test here.
The wfe instruction will do nothing and the b instruction unconditionally jumps back
to the label main.

This code will be simultaneously executed on every core of the ARM processor.

### Step 2 - Compiling

To compile the assembly file, use

```
aarch64-linux-gnu-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -c start.S -o start.o
```

This yields the start.o file.

### Step 3 - Linking

A linker takes sections from the compiler output and moves them around as described
by the linker file/script.

Linker files/scripts are documented here:
https://sourceware.org/binutils/docs/ld/

A linker file or script controls the linker and instructs it relocate sections in the binary/kernel image.
Relocating a section means that addresses in the code that is compiled into that section are changed to
the new address.

Save the following file as link.ld

```
SECTIONS
{
. = 0x80000;
.text : { \*(.text) }
}
```

The SECTIONS block defines all sections. The dot places the section marker at 0x80000 which is where aarch64
starts executing code. then a .text section is defined. Because the marker was not moved, .text starts at
0x80000. .text is the section that was used in the source file, hence this linker script takes the .text section
from the object file as an input and relocates this section to 0x80000. It is the relocated and contained
whithin the .elf file which is the output of the linker stage.

Now link the start.o object file to a .elf executable.

```
aarch64-linux-gnu-ld -nostdlib -nostartfiles start.o -T link.ld -o kernel8.elf
```

This yields kernel8.elf.

### Step 4 - Kernel Image Extraction

The .elf file that is the output of the linker stage is an executable file. It is executable on the
Linux operating system. The .elf format is specified here: https://refspecs.linuxbase.org/elf/elf.pdf

Windows has another format which is called PE.

The takeaway is that .elf is a complex format that contains subsections that are used by the Linux
operating system to retrieve the code stored within the .elf. The ARM CPU does not understand the
.elf format and we also do not have an operating system which can interpret .elf at this point so
.elf is useless to us.

The way to process from here is to extract the compiled and relocated machine code from the .elf file
to arrive at the kernel image.

To extract the kernel image from the .elf use the object copy tool:

```
aarch64-linux-gnu-objcopy -O binary kernel8.elf kernel8.img
```

This yields kernel8.img.

### Step 5 - Running

```
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img
```

To terminate:

Ctrl+a x

There is no output at all, because nothing is written anywhere in this first assembly program.

If you want to know what Qemu is doing, add the -d in_asm flag.

```
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img -d in_asm
```

Qemu will output, amongst other things:

---

IN:
0x00080000: d503205f wfe  
0x00080004: 17ffffff b #0x80000

This is the code from start.S

### Step 6 - Writing a Makefile

For convenience it would be easier if the build system part of the programming workflow could
be automated so that the developer does not have to type the same commands into the console
over and over. This speeds up the development cycle. The build tool make is used to achieve
a good level of automation.

NOTE: Make sure you respect make's convention of using tabs as part of it's syntax!
If you get errors from make, check your tabs first.

https://www.gnu.org/software/make/manual/html_node/Rule-Syntax.html

make is a build tool that reads its instructions from a file called Makefile which it expects in the current
working directory per default.

The Makefile contains rules:

```
targets : prerequisites
        recipe
```

The first rule in the Makefile is run as the default rule when no parameters are given to make.

A rule takes the prerequisits and looks at the target. If the target is older than the prerequisit,
make will execute the recipe to create current targets. If the target is as old as the prerequisits
make will not run any recipe and it will speed up the build that way. The idea is only perform
rules if prerequisits have changed.

On a more concrete level, prerequsist are assembly files, outputs are object files.
Also the kernel extraction from .elf can be formulated as a make rule.
The qemu emulator can be started using a phony target. A phony target has no prerequisits.

```
CFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles

all: clean kernel8.img

start.o: start.S
	aarch64-linux-gnu-gcc $(CFLAGS) -c start.S -o start.o

kernel8.img: start.o
	aarch64-linux-gnu-ld -nostdlib -nostartfiles start.o -T link.ld -o kernel8.elf
	aarch64-linux-gnu-objcopy -O binary kernel8.elf kernel8.img

clean:
	rm kernel8.elf kernel8.img *.o >/dev/null 2>/dev/null || true

run:
	/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img -d in_asm
```

With this makefile in the folder, typeing make in the command line will create a kernel.img.

```
make
```

Typing make run will not compile the code. Instead is will run qemu with a already compiled kernel.img
That means you have to call make at least once before make run will work.

```
make run
```

To clean all artifacts (= files that can be automatically generated and are not source code) type make clean

```
make clean
```
