# Makefile for compiling, linking, and flashing AVR programs to an microcontroller of choice.
# Begin Variables Section

## Program Section: change these variables based on your program
# The name of the program to build.
TARGET := hello

## Microcontroller Section: change these variables based on your microcontroller
# -----------------------------------------------------------------------------
# The running speed of the AVR in Hz, mostly used for `delay_ms` calculations and the `F_CPU` macro.
CLOCK_FREQ := 16000000UL
# The target microcontroller architecture (Atmega32U4)
# For a complete list, see https://gcc.gnu.org/onlinedocs/gcc/AVR-Options.html.
ARCH := atmega32u4
# The system path to communicate via serial, used for both flashing and serial
# monitoring. Defaults to the first port in /dev containing "tty.usb".
SERIAL_PORT := /dev/$(shell ls /dev/ | grep -i "ttyACM*" | sed -n 1p)
# UART baud default baud rate.
# baud rate for communication with microcontroller
BAUD_RATE := 9600

## AVRDUDE Section: change these variables based on your programmer
# -----------------------------------------------------------------------------
# Flashing baud rate.
# - 115200 (Arduino Uno)
# - 57600  (Arduino Mini Pro)
AVRDUDE_BAUD := 115200
# Programmer used to communicate with the AVR.
# For a complete list see `avrdude -c '?'`.
AVRDUDE_PROGRAMMER := avr109
# Part number of the device we're talking to. Typically related to the MMCU variable
# For a complete list see `avrdude -p '?'`.
AVRDUDE_PARTNO := m328p
# The avrdude executable.
AVRDUDE := sudo avrdude
# The avrdude flags.
AVRDUDE_FLAGS := -F -V -c $(AVRDUDE_PROGRAMMER) -p $(AVRDUDE_PARTNO)
# The avr-size executable.
AVRSIZE := avr-size
# The avr-size flags.
AVRSIZE_FLAGS := -C

## Compiler Section: change these variables based on your compiler
# -----------------------------------------------------------------------------
# The compiler executable.
CC := avr-gcc
# The compiler flags.
CFLAGS := -Os -DF_CPU=$(CLOCK_FREQ) -mmcu=$(ARCH)
# The objcopy executable.
OBJ_COPY := avr-objcopy
# The objcopy flags.
OBJ_COPY_FLAGS := -O ihex -R .eeprom
# The shell executable.
SHELL := /bin/bash

## Output Section: change these variables based on your output
# -----------------------------------------------------------------------------
# top directory of project
TOP_DIR := $(shell pwd)
# directory to locate source files
SRC_DIR := $(TOP_DIR)/src
# directory to locate header files
INC_DIR := $(TOP_DIR)/include
# directory to locate object files
OBJ_DIR := $(TOP_DIR)/obj
# directory to place build artifacts
BUILD_DIR := $(TOP_DIR)/target/$(ARCH)/release/

# header files to preprocess
INCS := -I$(INC_DIR)
# source files to compile
SRCS := $(wildcard $(SRC_DIR)/*.c)
# object files to link
OBJS := $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRCS))
# binary file to convert to hex
TARGET_BIN := $(BUILD_DIR)$(TARGET).bin
# hex file to flash
TARGET_HEX := $(BUILD_DIR)$(TARGET).hex

## Command Section: change these variables based on your commands
# -----------------------------------------------------------------------------
# Targets
.PHONY: all compile link hex flash clean

all: clean compile link hex flash

# $< and $@ are automatic variables that refer to the source (dependency) and target (build) files, respectively
# Use the AVR-GCC compiler to compile source files into an object file
compile: $(OBJS)

$(OBJS): $(SRCS)
	@mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) -c -o $(OBJS) $(SRCS)

# Use the AVR-GCC compiler to link the object file into an executable binary file
link: $(TARGET_BIN)

$(TARGET_BIN): $(OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) -mmcu=$(ARCH) -o $(TARGET_BIN) $(OBJS)

# Use the AVR-OBJCOPY tool to convert the executable binary file into a hex file
hex: $(TARGET_HEX)

$(TARGET_HEX): $(TARGET_BIN)
	$(OBJCOPY) $(OBJ_COPY_FLAGS) $(TARGET_BIN) $(TARGET_HEX)

# Use the AVR-DUDE tool to flash the hex file onto the microcontroller
flash: $(TARGET_HEX)
	$(AVRDUDE) -F -V -c $(AVRDUDE_PROGRAMMER) -p $(ARCH) -P $(SERIAL_PORT) -b $(BAUD_RATE) -U flash:w:$(TARGET_HEX):i

# Clean target: remove build artifacts and non-essential files
clean:
	@echo "Cleaning $(TARGET)..."
	rm -rf $(OBJ_DIR) $(BUILD_DIR)