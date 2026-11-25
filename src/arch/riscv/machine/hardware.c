#include <arch/types.h>
#include <arch/machine/hardware.h>
#include <plat/machine/hardware.h>

_Static_assert(sizeof(TrapFrame) == 272, "TrapFrame size mismatch with traps.S");
_Static_assert(__builtin_offsetof(TrapFrame, sepc) == 256, "sepc offset mismatch");
_Static_assert(__builtin_offsetof(TrapFrame, sstatus) == 264, "sstatus offset mismatch");

extern void trap_entry(void);
extern void restore_user_context(TrapFrame *tf);
extern void user_ping(void);
extern void user_pong(void);

void hal_main(void) {
    uint64_t stvec_val = ((uint64_t)trap_entry) & ~0x3ULL;
    asm volatile("csrw stvec, %0" :: "r"(stvec_val));

    asm volatile("csrs sie, %0" :: "r"(1ULL << 5));

    rust_kernel_init((uint64_t)user_ping, (uint64_t)user_pong);

    sbi_set_timer(read_time() + TIMER_TICK_INTERVAL);

    restore_user_context(rust_get_thread_frame(0));
}

TrapFrame *hal_dispatch_trap(TrapFrame *current_frame, uint64_t scause, uint64_t stval) {
    HalAction action = rust_kernel_handle_trap(current_frame, scause, stval);

    uint64_t cur_satp;
    asm volatile("csrr %0, satp" : "=r"(cur_satp));
    if (action.next_satp != 0 && action.next_satp != cur_satp) {
        setVSpaceRoot(action.next_satp);
    } else if (action.flush_tlb) {
        sfence_vma();
    }

    if (action.next_timer_cmp != 0) {
        sbi_set_timer(read_time() + action.next_timer_cmp);
    }

    if (action.ack_external_irq != 0) {
        plat_plic_complete(action.ack_external_irq);
    }

    return rust_get_thread_frame(action.next_thread_idx);
}
