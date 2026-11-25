#ifndef ARCH_RISCV_TYPES_H
#define ARCH_RISCV_TYPES_H

#include <stdint.h>

typedef struct __attribute__((packed, aligned(16))) {
    uint64_t x[32];
    uint64_t sepc;
    uint64_t sstatus;
} TrapFrame;

typedef struct {
    uint64_t next_satp;
    uint64_t next_timer_cmp;
    uint32_t next_thread_idx;
    uint8_t  flush_tlb;
    uint8_t  ack_external_irq;
} HalAction;

void rust_kernel_init(uint64_t entry0, uint64_t entry1);
HalAction rust_kernel_handle_trap(TrapFrame *current_frame, uint64_t scause, uint64_t stval);
TrapFrame *rust_get_thread_frame(uint32_t thread_idx);

#endif
