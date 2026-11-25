#ifndef PLAT_SPIKE_MACHINE_HARDWARE_H
#define PLAT_SPIKE_MACHINE_HARDWARE_H

#include <stdint.h>

#define UART0_BASE          0x10000000ULL
#define UART0_THR           ((volatile uint8_t *)(UART0_BASE + 0x00))
#define UART0_LSR           ((volatile uint8_t *)(UART0_BASE + 0x05))
#define UART0_LSR_TX_EMPTY  0x20

#define PLIC_BASE                   0x0C000000ULL
#define PLIC_S_CLAIM_COMPLETE_HART0 ((volatile uint32_t *)(PLIC_BASE + 0x201004ULL))

#define TIMER_TICK_INTERVAL 1000000ULL  /* ~100ms on QEMU 10MHz timer */

void plat_uart_putc(char c);
uint32_t plat_plic_claim(void);
void plat_plic_complete(uint32_t irq_id);

#endif
