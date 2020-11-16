# Programming in C

https://wiki.osdev.org/ARM_RaspberryPi_Tutorial_C

The goal of this lesson is to extend the development workflow from Lesson 01 and to add
support for the C programming language.

C is a high-level programming language and as such can be platform independant which makes
it possible to develop parts of the operating system so that it can run on other
hardware platforms later. The goal is to eventually run the OS on the Beaglebone Black besides the
Raspberry Pi 3 Model B+ later.

In order to get C support, a stack has to be set up and a bss section is required. The bss
section has to be initialized with zeroes.

## Relative label resolution (f)orward and (b)ehind.

https://stackoverflow.com/questions/27353096/1b-and-1f-in-gnu-assembly
https://stackoverflow.com/questions/48084634/what-does-b-mean-in-this-assembly-code

To understand start.S, first it is necessary to learn about the extension of gcc that allows
you to reference labels using the (f)orward and (b)ehind flags.

The b as in (b)ehind flag can be postfixed to a label name. gcc will resolve the label looking
backwords, that means if will search towards the start of the file until if finds the label.

An example is:

```
1:  wfe
    b       1b
```

Here, the label 1 is defined and one line later 1b is used. This will find the label 1
because the label is closer to the start of the file, hence behind will find it.

Another example is:

```
// read cpu id, stop slave cores
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
1:  wfe
    b       1b
2:  // cpu id == 0

    // set stack before our code
    ldr     x1, =_start
    mov     sp, x1
```

The line _cbz x1, 2f_ refernces the label 2 using a postfix (f)orward.
The label 2 is found because it is forward (towards the end of the file) relative
to the 2f instruction.

## linker.ld

```
SECTIONS
{
    . = 0x80000;

    .text :
    {
        KEEP(*(.text.boot))
        *(.text .text.* .gnu.linkonce.t*)
    }

    .rodata :
    {
        *(.rodata .rodata.* .gnu.linkonce.r*)
    }

    PROVIDE(_data = .);

    .data :
    {
        *(.data .data.* .gnu.linkonce.d*)
    }

    .bss (NOLOAD) : {
        . = ALIGN(16);
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        __bss_end = .;
    }

    _end = .;

   /DISCARD/ :
   {
       *(.comment)
       *(.gnu*)
       *(.note*)
       *(.eh_frame*)
    }
}
__bss_size = (__bss_end - __bss_start)>>3;
```

### KEEP()

https://sourceware.org/binutils/docs/ld/Input-Section-Keep.html#Input-Section-Keep
https://stackoverflow.com/questions/9827157/what-does-keep-mean-in-a-linker-script

KEEP() marks the roots of the dependency tree that spawns all sections. The linker tries
to remove unused sections that are not referenced from anywhere. root sections reference
other sections but they are not referenced themselves. KEEP prevents the linker from
removing your root sections.

### The \*() Notation

Remember lesson 01, where the linker script was explained and the _() notation was mentioned.
It is a wildcard that includes all object files that are fed into the linker. The linker will
now extract and copy all sections within the _() notation from those object files. If a specific
object file has to be excluded, the wildcard notation has to be adjusted.

### linkonce

https://stackoverflow.com/questions/5518083/what-is-a-linkonce-section
https://gcc.gnu.org/legacy-ml/gcc/2003-09/msg00984.html

DISCLAIMER: I am not 100% sure if this is correct.

.gnu.linkonce.t* and .gnu.linkonce.d* sections will be treated specially. If more than one
object file contributes a sections that is prefixed with .gnu.linkonce, only one of those
sections will be linked.

### PROVIDE

https://sourceware.org/binutils/docs/ld/PROVIDE.html

PROVIDE(\_data = .); causes the linker to define the \_data section itself. If the application als defines
\_data the linker will throw an error.

If the application however defines data without leading underscore the linker will use the definition
in the application.

If the application refernces data but does not define \_data nor data, the linker will provide it's own
implementation of the section.

DISCLAIMER: I am not sure if this is correct.
This is maybe used as a means to provide a section by the linker which can be used within the application.

### NOLOAD

https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_node/ld_21.html

The `(NOLOAD)' directive will mark a section to not be loaded at run time. The linker will process the section normally, but will mark it so that a program loader will not load it into memory.

TODO ??? what is the semantics of that and when is it usefull??? Way over my head!

## start.S

start.S sets up the stack and clears the .bss section.

How does the stack setup work and why do you have to initialize .bss to zero?
A very good explanation is given here: https://jsandler18.github.io/explanations/boot_S.html

The kernel is loaded by the hardware to address 0x80000 for 64 bit ARM and to 0x8000 for 32 bit ARM.
The kernel grows towards higher adresses. That is why it is safe to start the C-runtime stack at 0x80000
or 0x8000 for 32 bit and let it grow downwards towards the address 0. It won`t override the kernel.

The initialization to zero of the .bss section is required as .bss takes up global variables during
compilation. The C runtime specification says that global variables initially have the value 0.
This is achieved by zeroing out .bss manually as the compile does not perform this operation for us.

### Initializing the stack

```
ldr     x1, =_start
mov     sp, x1
```

The variable \_start is a label defined in the assembler file itself and points to the first byte
of the kernel code. ldr loads that address into x1. move then copies the value of x1 to sp.
sp is the stack pointer.

Now the stack pointer points to the beginning of the kernel code in memory. The stack pointer will
grow downwards toward zero whereas the kernel code is layed out towards higher addresses. This means
the stack will not grow into the kernel and it will not damage the kernel.

The only issue is that the stack pointer register sp points to the first byte of the kernel.
How is the first byte not overriden when the stack is used for the first time? The answer is that
the first stack instruction better be a push instruction and not a pop instruction. A pop instruction
before a push instruction would be a programming mistake. So if it is assumed that a push happens first,
then the stack pointer is decremented (stack grows downwords) and after that the value is pushed.
That means that the first push operation does not override the first byte in the kernel because the
stack pointer is decremented before a value is written. That means the push does not write data into the
kernel at all.

### Clearing .bss / Filling .bss with zeroes

.bss is cleared with this piece of assembly:

```
    // clear bss
    ldr     x1, =__bss_start
    ldr     w2, =__bss_size
3:  cbz     w2, 4f
    str     xzr, [x1], #8
    sub     w2, w2, #1
    cbnz    w2, 3b
```

The first thing of importance is that start.S uses the variables \_\_bss_start and \_\_bss_size.
These variables are defined by the linker script link.ld.

Another point is the use of registers called x and w. x is a 64 bit register whereas w are the lower
32 bit of a 64 bit register. For example x1 and w1 both use the register 1 but x1 uses all 64 bits
of register 1 whereas w1 only uses the lower 32 bit of register 1. (https://developer.arm.com/architectures/learn-the-architecture/aarch64-instruction-set-architecture/registers-in-aarch64-general-purpose-registers)

The code above that clears the .bss section will first determine how many bytes the .bss section has and
it will then iterate over all bytes. Once it is done, it jumps to the main function of the C application.

```
ldr     x1, =__bss_start
```

loads \_\_bss_start into the register x1 using the pseudo instruction ldr (https://www.keil.com/support/man/docs/armasm/armasm_dom1361289875065.htm). Do not confuse the pseude instruction ldr with the real instruction ldr. The difference
is the equals sign prefixed to the variable \_\_bss_start.

```
ldr     w2, =__bss_size
```

loads \_\_bss_size into the register w2. Again it uses the pseudo ldr.

```
3:  cbz     w2, 4f
```

Defines the label 3, then calls cbz (Compare and Branch on Zero) which jumps to the label 4 (f)orward searched if
the register w2 contains a zero. Otherwise just increments the instruction pointer so that the next instruction
is executed. This basically is the loop condition, which is loop unless w2 is zero.

```
str     xzr, [x1], #8
```

This line uses the (immediate offset) variant of str (store) (https://www.keil.com/support/man/docs/armasm/armasm_dom1361289906890.htm). This line will take the value that is
currently contained in the xzr register and writes it into memory using an address that is computed using
x1 as a base and an immediate offset of 8 added on top of the base.

NOTE START: I am not sure if the following explanation of STR is actually true or not... Handle with care!

STR will then update the base register
x1 with the computation x1 = x1 + #8. The offset of #8 is 8x8 byte = 64 byte which is one the next DWord.

The str instruction with an immediate offset is the reason why the loop walks over every DWORD in the
.bss section and writes a zero into it.

NOTE END: From here on I am sure again.

The register xzr is special (https://stackoverflow.com/questions/42788696/why-might-one-use-the-xzr-register-instead-of-the-literal-0-on-armv8)

xzr apparently is synonymous to zero in most cases. Using xzr saves the CPU from using a register
to store the value 0 before assigning that zero to another register. Instead using xzr the zero
immediately finds its way into the destination register without taking up a register in between.

```
sub     w2, w2, #1
```

Decrements w2 by one. As w2 initially stores \_\_bss_size this moves the loop to the next byte.

```
cbnz    w2, 3b
```

Uses Compare and Branch on Non-Zero with the register w2 and moves back to the label 3 unless
w2 is zero in which case the next instruction is executed and no jump is performed.

## Trash

aarch64-linux-gnu-as -c start.S -o start.o

aarch64-linux-gnu-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -c start.S -o start.o

https://stackoverflow.com/questions/27353096/1b-and-1f-in-gnu-assembly
https://stackoverflow.com/questions/48084634/what-does-b-mean-in-this-assembly-code

aarch64-linux-gnu-gcc -I/usr/lib/gcc-cross/aarch64-linux-gnu/9/include -I/usr/aarch64-linux-gnu/include/linux -I/usr/aarch64-linux-gnu/include -std=gnu99 -Wall -Wextra -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -c kernel.c -o kernel.o

THIS WORKS:
aarch64-linux-gnu-gcc -I/usr/lib/gcc-cross/aarch64-linux-gnu/9/include -std=gnu99 -Wall -Wextra -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -c kernel.c -o kernel.o

????
aarch64-linux-gnu-gcc -std=gnu99 \
-I/usr/lib/gcc-cross/aarch64-linux-gnu/9/include \
-I/usr/aarch64-linux-gnu/include/linux \
-I/usr/aarch64-linux-gnu/include \
-Wall -Wextra -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -c kernel.c -o kernel.o

aarch64-elf-gcc -T link.ld -o myos.elf -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

THIS WORKS:
aarch64-linux-gnu-ld -nostdlib -nostartfiles start.o kernel.o -T link.ld -o kernel8.elf

aarch64-elf-objcopy myos.elf -O binary kernel8.img

THIS WORKS:
aarch64-linux-gnu-objcopy -O binary kernel8.elf kernel8.img

/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img
/tmp/qemu/aarch64-softmmu/qemu-system-aarch64 -nographic -M raspi3 -kernel kernel8.img -serial stdio

cd /home/dev/Lesson02_C
cd /usr/aarch64-linux-gnu

clear
grep -rnw '/path/to/somewhere/' -e 'pattern'
clear
grep -rnw '/usr/aarch64-linux-gnu/' -e 'size_t'

```
$ find . -name stddef.h
./tmp/qemu/roms/ipxe/src/include/stddef.h
./tmp/qemu/roms/edk2/CryptoPkg/Library/Include/stddef.h
./tmp/qemu/roms/u-boot/include/linux/stddef.h
./tmp/qemu/roms/u-boot-sam460ex/include/linux/stddef.h
./tmp/qemu/roms/SLOF/lib/libc/include/stddef.h
./usr/lib/gcc-cross/alpha-linux-gnu/9/include/stddef.h
./usr/lib/gcc-cross/powerpc64-linux-gnu/9/include/stddef.h
./usr/lib/gcc-cross/s390x-linux-gnu/9/include/stddef.h
./usr/lib/gcc-cross/aarch64-linux-gnu/9/include/stddef.h
./usr/lib/gcc/x86_64-linux-gnu/9/include/stddef.h
./usr/include/linux/stddef.h
./usr/aarch64-linux-gnu/include/linux/stddef.h
./usr/alpha-linux-gnu/include/linux/stddef.h
```
