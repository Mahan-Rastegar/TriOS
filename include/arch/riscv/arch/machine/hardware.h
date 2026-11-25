#ifndef ARCH_RISCV_MACHINE_HARDWARE_H
#define ARCH_RISCV_MACHINE_HARDWARE_H

#include <stdint.h>

static inline uint64_t read_scause(void) {
    uint64_t val;
    asm volatile("csrr %0, scause" : "=r"(val));
    return val;
}

static inline uint64_t read_stval(void) {
    uint64_t val;
    asm volatile("csrr %0, stval" : "=r"(val));
    return val;
}

static inline uint64_t read_time(void) {
    uint64_t val;
    asm volatile("csrr %0, time" : "=r"(val));
    return val;
}

static inline void sfence_vma(void) {
    asm volatile("sfence.vma zero, zero" ::: "memory");
}

static inline void setVSpaceRoot(uint64_t satp_val) {
    asm volatile("csrw satp, %0" :: "r"(satp_val) : "memory");
    sfence_vma();
}

static inline void sbi_set_timer(uint64_t stime_value) {
    register uint64_t a0 asm("a0") = stime_value;
    register uint64_t a6 asm("a6") = 0;
    register uint64_t a7 asm("a7") = 0x54494D45;
    asm volatile("ecall" : "+r"(a0) : "r"(a6), "r"(a7) : "memory");
}

#endif
