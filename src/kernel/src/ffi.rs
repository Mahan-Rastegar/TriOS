use crate::sched::{HalAction, KernelState, TrapFrame, NUM_THREADS};

extern "C" {
    fn plat_uart_putc(c: u8);
}

static mut KERNEL: KernelState = KernelState::new();

#[no_mangle]
pub extern "C" fn rust_kernel_init(entry0: u64, entry1: u64) {
    unsafe {
        KERNEL.init(entry0, entry1);
    }
}

#[no_mangle]
pub extern "C" fn rust_kernel_handle_trap(
    _current_frame: *mut TrapFrame,
    scause: u64,
    stval: u64,
) -> HalAction {
    let (action, out_char) = unsafe { KERNEL.handle_trap(scause, stval) };

    if let Some(ch) = out_char {
        unsafe {
            plat_uart_putc(ch);
        }
    }

    action
}

#[no_mangle]
pub extern "C" fn rust_get_thread_frame(thread_idx: u32) -> *mut TrapFrame {
    let idx = (thread_idx as usize) % NUM_THREADS;
    unsafe { &mut KERNEL.threads[idx] as *mut TrapFrame }
}
