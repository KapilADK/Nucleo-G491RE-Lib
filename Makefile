# Toolchain Definitions
CC 	    := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
SIZE 	:= arm-none-eabi-size
OBJDUMP := arm-none-eabi-objdump

SRC_FOLDER   := Src
BUILD_FOLDER := build
SRC_DEPENDS  = $(shell find $(SRC_FOLDER) -name '*.c')
OBJ_DEPENDS  := $(patsubst $(SRC_FOLDER)/%.c, $(BUILD_FOLDER)/%.o, $(SRC_DEPENDS))

LDSCRIPT := linker.ld

TARGET := firmware

# FLAGS
CPU_FLAGS := -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard

CFLAGS := $(CPU_FLAGS) \
		  -DSTM32G491xx \
		  -Wall -Werror \
		  -Og -g3 \
		  -ffunction-sections \
		  -fdata-sections

LDFLAGS := -T $(LDSCRIPT) \
		   -Wl,--gc-sections,-Map=$(BUILD_FOLDER)/$(TARGET).map \
		   --specs=nano.specs

.PHONY: all clean hex bin flash list-headers

all: $(BUILD_FOLDER)/$(TARGET).elf
	$(SIZE) $<


$(BUILD_FOLDER)/$(TARGET).elf: $(OBJ_DEPENDS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(BUILD_FOLDER)/%.o: $(SRC_FOLDER)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $^ -o $@

hex: $(BUILD_FOLDER)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $(BUILD_FOLDER)/$(TARGET).hex

bin: $(BUILD_FOLDER)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $(BUILD_FOLDER)/$(TARGET).bin

flash: $(BUILD_FOLDER)/$(TARGET).elf
	openocd -f interface/stlink.cfg -f target/stm32g4x.cfg -c "program $< verify reset exit"

list-headers: 
	$(OBJDUMP) -h $(BUILD_FOLDER)/$(TARGET).elf

clean:
	rm -rf $(BUILD_FOLDER)
