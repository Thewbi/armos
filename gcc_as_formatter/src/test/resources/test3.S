faculty:

    push {lr}

    cmp r0, #0x00
    bne continue_faculty
    mov r0, #0x01
    b return_faculty /* test
    test */

continue_faculty:
    push {r0}
    sub r0, r0, #0x01
    bl faculty
bla:    mov r1, r0

    pop {r0}

    mul r0, r0, r1 // test

return_faculty:
    pop {lr}
    /* return to caller. r15 is the programm counter. r14 is the link register */
    mov pc, lr
