CC          = riscv64-linux-gnu-gcc
LD          = riscv64-linux-gnu-ld
CARGO       = cargo
QEMU        = qemu-system-riscv64

RUST_TARGET = riscv64gc-unknown-none-elf
RUST_LIB    = src/kernel/target/$(RUST_TARGET)/release/libtrios_kernel.a

LDSCRIPT    = src/arch/riscv/linker.lds

CFLAGS      = -march=rv64gc -mabi=lp64d -mcmodel=medany \
              -ffreestanding -nostdlib -fno-builtin -fno-stack-protector -Wall -Wextra -O2 \
              -Iinclude/arch/riscv -Iinclude/plat/spike

ASFLAGS     = -march=rv64gc -mabi=lp64d -mcmodel=medany

BUILD_DIR   = build
KERNEL_ELF  = $(BUILD_DIR)/kernel.elf

OBJS = \
	$(BUILD_DIR)/head.o \
	$(BUILD_DIR)/traps.o \
	$(BUILD_DIR)/arch_hardware.o \
	$(BUILD_DIR)/plat_hardware.o \
	$(BUILD_DIR)/ping_pong.o

.PHONY: all rust run clean

all: $(KERNEL_ELF)

rust:
	$(CARGO) build --manifest-path src/kernel/Cargo.toml --release --target $(RUST_TARGET)

$(BUILD_DIR)/head.o: src/arch/riscv/head.S
	@mkdir -p $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/traps.o: src/arch/riscv/traps.S
	@mkdir -p $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/arch_hardware.o: src/arch/riscv/machine/hardware.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/plat_hardware.o: src/plat/spike/machine/hardware.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/ping_pong.o: user/ping_pong.S
	@mkdir -p $(BUILD_DIR)
	$(CC) $(ASFLAGS) -c $< -o $@

$(KERNEL_ELF): rust $(OBJS) $(LDSCRIPT)
	$(LD) -T $(LDSCRIPT) $(OBJS) $(RUST_LIB) -o $@

run: $(KERNEL_ELF)
	$(QEMU) -machine virt -nographic -kernel $(KERNEL_ELF)

clean:
	rm -rf $(BUILD_DIR)
	$(CARGO) clean --manifest-path src/kernel/Cargo.toml
