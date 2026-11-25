.section .text
.globl user_ping
.globl user_pong

.equ SYS_PUTC,  1
.equ SYS_YIELD, 2

user_ping:
1:
    li      a7, SYS_PUTC
    li      a0, '['
    ecall
    li      a0, 'P'
    ecall
    li      a0, 'I'
    ecall
    li      a0, 'N'
    ecall
    li      a0, 'G'
    ecall
    li      a0, ']'
    ecall
    li      a0, ' '
    ecall

    li      t0, 2000000
2:  addi    t0, t0, -1
    bnez    t0, 2b

    li      a7, SYS_YIELD
    ecall
    j       1b

user_pong:
1:
    li      a7, SYS_PUTC
    li      a0, '['
    ecall
    li      a0, 'P'
    ecall
    li      a0, 'O'
    ecall
    li      a0, 'N'
    ecall
    li      a0, 'G'
    ecall
    li      a0, ']'
    ecall
    li      a0, '\r'
    ecall
    li      a0, '\n'
    ecall

    li      t0, 2000000
2:  addi    t0, t0, -1
    bnez    t0, 2b

    li      a7, SYS_YIELD
    ecall
    j       1b
