#![no_std]

pub mod ffi;
pub mod sched;

use core::panic::PanicInfo;

extern "C" {
    fn plat_uart_putc(c: u8);
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    for &b in b"\r\n!KERNEL PANIC!\r\n" {
        unsafe {
            plat_uart_putc(b);
        }
    }
    loop {
        core::hint::spin_loop();
    }
}
