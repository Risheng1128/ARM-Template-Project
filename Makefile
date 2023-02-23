# ------------------------------------------------
# Generic Makefile
# 
# Author: Ri-Sheng Chen
# ------------------------------------------------

OUT = build
BIN = main

C_SRC = syscalls.c \
	    usart.c \
	    $(BIN).c
ASM_SRC = startup.s
LDSCRIPT = src/link.ld

TOOLCHAIN = arm-none-eabi-
CC = $(TOOLCHAIN)gcc
SZ = $(TOOLCHAIN)size

MCU = -mthumb -mcpu=cortex-m4
C_INC = -Iinc
CFLAGS = $(MCU) $(C_INC) -O0 -Wall
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) -lc -lm -lnosys

OBJS = $(patsubst %.c, $(OUT)/%.o, $(C_SRC))
OBJS += $(patsubst %.s, $(OUT)/%.o, $(ASM_SRC))

all: $(OUT)/$(BIN)
$(OUT)/%.o: src/%.c
	$(CC) -c $(CFLAGS) $< -o $@
$(OUT)/%.o: src/%.s
	$(CC) -c $(CFLAGS) $< -o $@
$(OUT)/$(BIN): $(OUT) $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@
	$(SZ) $@
$(OUT):
	echo $(OBJS)
	mkdir $@

.PHONY: disassembly load upload clean
disassembly: $(OUT)/$(BIN)
	$(TOOLCHAIN)objdump -d $^ > $(OUT)/$(BIN).S
debug:
	openocd -f board/st_nucleo_f3.cfg
upload:
	openocd -f interface/stlink-v2-1.cfg -f target/stm32f3x.cfg -c " program $(OUT)/$(BIN) verify exit "
clean:
	-@rm -r $(OUT)