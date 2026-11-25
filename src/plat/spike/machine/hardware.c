#include <plat/machine/hardware.h>

void plat_uart_putc(char c) {
    while ((*UART0_LSR & UART0_LSR_TX_EMPTY) == 0) {}
    *UART0_THR = (uint8_t)c;
}

uint32_t plat_plic_claim(void) {
    return *PLIC_S_CLAIM_COMPLETE_HART0;
}

void plat_plic_complete(uint32_t irq_id) {
    *PLIC_S_CLAIM_COMPLETE_HART0 = irq_id;
}
