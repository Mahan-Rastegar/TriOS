OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS {
    . = 0x80200000;

    .text : {
        *(.boot.text)
        *(.text .text.*)
    }

    .rodata : ALIGN(4096) {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(4096) {
        *(.data .data.*)
        PROVIDE(__global_pointer$ = . + 0x800);
    }

    .bss : ALIGN(4096) {
        . = ALIGN(8);
        _bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(8);
        _bss_end = .;

        . = ALIGN(16);
        _kernel_stack_bottom = .;
        . += 65536; /* 64 KiB S-mode kernel stack */
        _kernel_stack_top = .;
    }
}
