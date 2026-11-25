.section .text
.align 4
.globl trap_entry
.globl restore_user_context

.equ TF_RA,      8
.equ TF_SP,      16
.equ TF_GP,      24
.equ TF_TP,      32
.equ TF_T0,      40
.equ TF_T1,      48
.equ TF_T2,      56
.equ TF_S0,      64
.equ TF_S1,      72
.equ TF_A0,      80
.equ TF_A1,      88
.equ TF_A2,      96
.equ TF_A3,      104
.equ TF_A4,      112
.equ TF_A5,      120
.equ TF_A6,      128
.equ TF_A7,      136
.equ TF_S2,      144
.equ TF_S3,      152
.equ TF_S4,      160
.equ TF_S5,      168
.equ TF_S6,      176
.equ TF_S7,      184
.equ TF_S8,      192
.equ TF_S9,      200
.equ TF_S10,     208
.equ TF_S11,     216
.equ TF_T3,      224
.equ TF_T4,      232
.equ TF_T5,      240
.equ TF_T6,      248
.equ TF_SEPC,    256
.equ TF_SSTATUS, 264

trap_entry:
    csrrw   t0, sscratch, t0
    beqz    t0, _kernel_panic_hang

    sd      ra,  TF_RA(t0)
    sd      sp,  TF_SP(t0)
    sd      gp,  TF_GP(t0)
    sd      tp,  TF_TP(t0)
    sd      t1,  TF_T1(t0)
    sd      t2,  TF_T2(t0)
    sd      s0,  TF_S0(t0)
    sd      s1,  TF_S1(t0)
    sd      a0,  TF_A0(t0)
    sd      a1,  TF_A1(t0)
    sd      a2,  TF_A2(t0)
    sd      a3,  TF_A3(t0)
    sd      a4,  TF_A4(t0)
    sd      a5,  TF_A5(t0)
    sd      a6,  TF_A6(t0)
    sd      a7,  TF_A7(t0)
    sd      s2,  TF_S2(t0)
    sd      s3,  TF_S3(t0)
    sd      s4,  TF_S4(t0)
    sd      s5,  TF_S5(t0)
    sd      s6,  TF_S6(t0)
    sd      s7,  TF_S7(t0)
    sd      s8,  TF_S8(t0)
    sd      s9,  TF_S9(t0)
    sd      s10, TF_S10(t0)
    sd      s11, TF_S11(t0)
    sd      t3,  TF_T3(t0)
    sd      t4,  TF_T4(t0)
    sd      t5,  TF_T5(t0)
    sd      t6,  TF_T6(t0)

    csrrw   t1, sscratch, zero
    sd      t1, TF_T0(t0)

    csrr    t1, sepc
    sd      t1, TF_SEPC(t0)
    csrr    t1, sstatus
    sd      t1, TF_SSTATUS(t0)

    la      sp, _kernel_stack_top
    mv      a0, t0
    csrr    a1, scause
    csrr    a2, stval
    call    hal_dispatch_trap

restore_user_context:
    mv      t0, a0

    ld      t1, TF_SEPC(t0)
    csrw    sepc, t1
    ld      t1, TF_SSTATUS(t0)
    csrw    sstatus, t1

    csrw    sscratch, t0

    ld      ra,  TF_RA(t0)
    ld      sp,  TF_SP(t0)
    ld      gp,  TF_GP(t0)
    ld      tp,  TF_TP(t0)
    ld      t1,  TF_T1(t0)
    ld      t2,  TF_T2(t0)
    ld      s0,  TF_S0(t0)
    ld      s1,  TF_S1(t0)
    ld      a0,  TF_A0(t0)
    ld      a1,  TF_A1(t0)
    ld      a2,  TF_A2(t0)
    ld      a3,  TF_A3(t0)
    ld      a4,  TF_A4(t0)
    ld      a5,  TF_A5(t0)
    ld      a6,  TF_A6(t0)
    ld      a7,  TF_A7(t0)
    ld      s2,  TF_S2(t0)
    ld      s3,  TF_S3(t0)
    ld      s4,  TF_S4(t0)
    ld      s5,  TF_S5(t0)
    ld      s6,  TF_S6(t0)
    ld      s7,  TF_S7(t0)
    ld      s8,  TF_S8(t0)
    ld      s9,  TF_S9(t0)
    ld      s10, TF_S10(t0)
    ld      s11, TF_S11(t0)
    ld      t3,  TF_T3(t0)
    ld      t4,  TF_T4(t0)
    ld      t5,  TF_T5(t0)
    ld      t6,  TF_T6(t0)
    ld      t0,  TF_T0(t0)

    sret

_kernel_panic_hang:
    wfi
    j       _kernel_panic_hang
