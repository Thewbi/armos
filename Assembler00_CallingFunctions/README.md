# Calling Functions / Routines

https://community.arm.com/developer/ip-products/processors/b/processors-ip-blog/posts/how-to-call-a-function-from-arm-assembler

Routine and Function are used synonymous.

Functions allow to group instructions together that fulfill a recuring functionality. The functionality can be reused more easily or even moved into a library for reuse. Also functions help with organizing code. When choosing a descriptive function name, the code also gets some basic documentation.

The branch with link (bl) instruction jumps to a label and saves the current address, that is currently stored in the programm counter register (r15) into the link register (r14).

The inverse operation to bl is to copy the value from the link register (r14) back into the program counter register (r15) which effectively returns from the function and makes the CPU pick up after the function call.

```
    ...
    bl routine_1
    ...

routine_1:
    ...

    // return from the function
    mov     pc, lr
```

This basic principle has to be extended.

It has to cover

- Passing paramters to the function (scratch registers r0-r3 and r12)
- Returning a value from a function call (return value)
- Storing and restoring of preserve registers (r4 - r11).
- Nested calls to functions within functions (Recursion is a special case of nesting) which means storing the return address and restoring it after the nested function call.
- How to call functions from C code.

# Nested Calls

Setting up a stack

# Call a assembler function from C code

## In assembly

1. Define the function

```
/* Check if another character can be written and if the fifo is empty, write the character.
The character is expected to be stored in r2.
*/
writeCharacter:
    ldr r3, [r1, #0x18]
    and r3, r3, #0x20
    cmp r3, #0
    bne writeCharacter
    str r2, [r1, #0x0000] /* str r2, [r1, #0x0000] actually writes a character to the UART */

    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr
```

2. Define the function as .globl or .global so it can be seen from C code

```
.globl writeCharacter
```

## In the C code

1. define the function prototype as extern:
   extern void writeCharacter();

2. Call the function in C
   writeCharacter();

3. link all object files together

# Passing parameters to assembler function from C functions

https://community.arm.com/developer/ip-products/processors/b/processors-ip-blog/posts/function-parameters-on-32-bit-arm

When a function defined in assembler is called from C code, the supplied parameters are inserted into the registers
r0, r1, r2, r3

what happens if there are more than 4 parameters?

That means a function call like this:

```
writeCharacter('a', 'a', 'a');
```

puts the character 'a' into r0, r1 and r2. r3 is unchanged and still contains the value it did contain before.

# Returning values from assembler to C functions

The return value is expected in r0.

Example:

```
_get_stack_pointer:
    // Return the stack pointer value
    str     sp, [sp]
    ldr     r0, [sp]

    // return from the function
    mov     pc, lr
```
