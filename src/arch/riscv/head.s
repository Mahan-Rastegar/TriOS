.section .boot.text, "ax"
.globl _start

_start:
    bnez    a0, 3f

    csrw    sie, zero
    csrw    sip, zero

.option push
.option norelax
    la      gp, __global_pointer$
.option pop

    la      t0, _bss_start
    la      t1, _bss_end
1:  bgeu    t0, t1, 2f
    sd      zero, 0(t0)
    addi    t0, t0, 8
    j       1b

2:
    la      sp, _kernel_stack_top
    call    hal_main

3:  wfi
    j       3b
