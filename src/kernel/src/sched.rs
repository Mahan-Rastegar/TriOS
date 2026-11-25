#[repr(C, align(16))]
#[derive(Copy, Clone)]
pub struct TrapFrame {
    pub x: [u64; 32],
    pub sepc: u64,
    pub sstatus: u64,
}

impl TrapFrame {
    pub const fn new() -> Self {
        Self {
            x: [0; 32],
            sepc: 0,
            sstatus: 0,
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct HalAction {
    pub next_satp: u64,
    pub next_timer_cmp: u64,
    pub next_thread_idx: u32,
    pub flush_tlb: u8,
    pub ack_external_irq: u8,
}

pub const NUM_THREADS: usize = 2;

const SCAUSE_INTERRUPT_BIT: u64 = 1 << 63;
const SCAUSE_SUPERVISOR_TIMER: u64 = SCAUSE_INTERRUPT_BIT | 5;
const SCAUSE_ECALL_FROM_U: u64 = 8;

const UMODE_INITIAL_SSTATUS: u64 = 1 << 5;

const TIMER_TICK_INTERVAL: u64 = 1_000_000;

const SYS_PUTC: u64 = 1;
const SYS_YIELD: u64 = 2;

pub struct KernelState {
    pub threads: [TrapFrame; NUM_THREADS],
    pub current: usize,
}

impl KernelState {
    pub const fn new() -> Self {
        Self {
            threads: [TrapFrame::new(), TrapFrame::new()],
            current: 0,
        }
    }

    pub fn init(&mut self, entry0: u64, entry1: u64) {
        self.threads[0] = TrapFrame::new();
        self.threads[0].sepc = entry0;
        self.threads[0].sstatus = UMODE_INITIAL_SSTATUS;

        self.threads[1] = TrapFrame::new();
        self.threads[1].sepc = entry1;
        self.threads[1].sstatus = UMODE_INITIAL_SSTATUS;

        self.current = 0;
    }

    pub fn handle_trap(&mut self, scause: u64, _stval: u64) -> (HalAction, Option<u8>) {
        let mut out_char: Option<u8> = None;
        let mut next_timer_cmp: u64 = 0;

        if scause == SCAUSE_ECALL_FROM_U {
            self.threads[self.current].sepc = self.threads[self.current].sepc.wrapping_add(4);

            let syscall_id = self.threads[self.current].x[17];
            let arg0 = self.threads[self.current].x[10];

            match syscall_id {
                SYS_PUTC => {
                    out_char = Some((arg0 & 0xFF) as u8);
                }
                SYS_YIELD => {
                    self.current = (self.current + 1) % NUM_THREADS;
                }
                _ => {
                    self.threads[self.current].x[10] = u64::MAX;
                }
            }
        } else if scause == SCAUSE_SUPERVISOR_TIMER {
            self.current = (self.current + 1) % NUM_THREADS;
            next_timer_cmp = TIMER_TICK_INTERVAL;
        } else {
            panic!("Unhandled trap");
        }

        let action = HalAction {
            next_satp: 0,
            next_timer_cmp,
            next_thread_idx: self.current as u32,
            flush_tlb: 0,
            ack_external_irq: 0,
        };

        (action, out_char)
    }
}
