/******************************************************************************
*	main.s
*	 by Alex Chadwick
*
*	A sample assembly code implementation of the input01 operating system, that
*	displays keyboard inputs as text on screen.
*
*	main.s contains the main operating system, and IVT code.
******************************************************************************/

/*
* .globl is a directive to our assembler, that tells it to export this symbol
* to the elf file. Convention dictates that the symbol _start is used for the
* entry point, so this all has the net effect of setting the entry point here.
* Ultimately, this is useless as the elf itself is not used in the final
* result, and so the entry point really doesn't matter, but it aids clarity,
* allows simulators to run the elf, and also stops us getting a linker warning
* about having no entry point.
*/
.section .init
.globl _start
_start:

/*
* Branch to the actual main code.
*/
b main

/*
* This command tells the assembler to put this code with the rest.
*/
.section .text

/*
* main is what we shall call our main operating system method. It never
* returns, and takes no parameters.
* C++ Signature: void main(void)
*/
main:

/*
* Set the stack point to 0x8000.
*/
	mov sp,#0x8000

/*
 * initialise UART to output characters over serial
 */
    bl initUart

/*
* Setup the screen.
*/

	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitialiseFrameBuffer

/*
* Check for a failed frame buffer.
*/
	teq r0,#0
	bne noError$

	mov r0,#16
	mov r1,#1
	bl SetGpioFunction

	mov r0,#16
	mov r1,#0
	bl SetGpio

	error$:
		b error$

	noError$:

	fbInfoAddr .req r4
	mov fbInfoAddr,r0

/*
* Let our drawing method know where we are drawing to.
*/
	bl SetGraphicsAddress

	bl UsbInitialise

	mov r4, #0
	mov r5, #0
loopContinue$:

	bl KeyboardUpdate
	bl KeyboardGetChar

	teq r0, #0
	beq loopContinue$

    /* output character to uart */
    mov r2, r0
    bl writeCharacter

    /* render the character to the frame buffer */
	mov r1, r4
	mov r2, r5
	bl DrawCharacter

	add r4, r0

	teq r4, #1024
	addeq r5, r1
	moveq r4, #0
	teqeq r5, #768
	moveq r5, #0



	b loopContinue$

