# ===== Runtime =====
RUNTIME  = /home/guisb_ubuntu/tinyqv/ProgramasC/runtime
STARTUP  = $(RUNTIME)/start.S
LDSCRIPT = $(RUNTIME)/linker.ld

# ===== Toolchain =====
CC      = /home/guisb_ubuntu/tinyqv/TinyQVSDK/toolchain/bin/riscv32-unknown-elf-gcc
OBJCOPY = /home/guisb_ubuntu/tinyqv/TinyQVSDK/toolchain/bin/riscv32-unknown-elf-objcopy
OBJDUMP = /home/guisb_ubuntu/tinyqv/TinyQVSDK/toolchain/bin/riscv32-unknown-elf-objdump

# ===== Flags =====
CFLAGS  = -march=rv32ec -mabi=ilp32e -nostdlib -ffreestanding -O2
LDFLAGS = -T $(LDSCRIPT)

# ===== Target =====
TARGET = teste3

all: $(TARGET).hex

$(TARGET).elf: $(TARGET).c $(STARTUP) $(LDSCRIPT)
	$(CC) $(CFLAGS) $(STARTUP) $(TARGET).c $(LDFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) $< -O binary $@

$(TARGET).hex: $(TARGET).bin
	od -An -t x1 -w4 -v $< > $@

clean:
	rm -f *.elf *.bin *.hex
