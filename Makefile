# Makefile for compiling, linking, and flashing AVR programs to an microcontroller of choice

# Begin Variables Section

## Microcontroller Section: change these variables based on your microcontroller
# -----------------------------------------------------------------------------
# The running speed of the AVR in Hz, mostly used for `delay_ms` time
# calculations.
# The running speed of the AVR in Hz, mostly used for `delay_ms` calculations and the `F_CPU` macro.
CLOCK_FREQ := 16000000UL

# target microcontroller architecture (Atmega32U4)
# For a complete list, see https://gcc.gnu.org/onlinedocs/gcc/AVR-Options.html.
ARCH := atmega32u4
# serial port microcontroller is connected to
# The system path to communicate via serial, used for both flashing and serial
# monitoring. Defaults to the first port in /dev containing "tty.usb".
SERIAL_PORT := /dev/$(shell ls /dev/ | grep -i "ttyACM*" | sed -n 1p)
# UART baud default baud rate.
# baud rate for communication with microcontroller
BAUD_RATE := 9600

## AVRDUDE Section: change these variables based on your programmer
# -----------------------------------------------------------------------------
# Flashing baud rate.
#
# - 115200 (Arduino Uno)
# - 57600  (Arduino Mini Pro)
AVRDUDE_BAUD := 115200

# Programmer used to communicate with the AVR.
# For a complete list see `avrdude -c '?'`.
AVRDUDE_PROGRAMMER := avr109

# Partno of the device we're talking to. Typically related to the MMCU variable
# For a complete list see `avrdude -p '?'`.
AVRDUDE_PARTNO := m328p

## Compiler Section: change these variables based on your compiler
# -----------------------------------------------------------------------------
# The `avr-gcc` executable.
CC := avr-gcc
# CFLAGS = -Wall -Werror -pedantic -Os -std=c99 \
         -DF_CPU=$(CLOCK_FREQ) -mmcu=$(ARCH) \
	 -I. $(DEPENDENCIES:%=-I%/include)
CFLAGS := -Os -DF_CPU=$(CLOCK_FREQ) -mmcu=$(ARCH)

# The `obj-copy` executable.
OBJ_COPY := avr-objcopy
OBJ_COPY_FLAGS := -O ihex -R .eeprom

# The `avrdude` executable.
AVRDUDE := sudo avrdude
AVRDUDE_FLAGS := -F -V -c $(AVRDUDE_PROGRAMMER) -p $(AVRDUDE_PARTNO)

# The `avr-size` executable.
AVRSIZE := avr-size
AVRSIZE_FLAGS := -C

## Output Section: change these variables based on your output
# -----------------------------------------------------------------------------
# top directory of project
TOP_DIR := $(shell pwd)

# source files to compile
SOURCE := $(TOP_DIR)/src/main.c
# directory to place build artifacts
BUILD_DIR := $(TOP_DIR)/target/$(ARCH)/release/
# name of target executable

TARGET := hello
# object file to link
TARGET_OBJ := $(BUILD_DIR)$(TARGET).o
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
compile: $(TARGET_OBJ)

$(TARGET_OBJ): $(SOURCE)
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $(TARGET_OBJ) $(SOURCE) 

# Use the AVR-GCC compiler to link the object file into an executable binary file
link: $(TARGET_BIN)

$(TARGET_BIN): $(TARGET_OBJ)
	$(CC) -mmcu=$(ARCH) -o $(TARGET_BIN) $(TARGET_OBJ)

# Use the AVR-OBJCOPY tool to convert the executable binary file into a hex file
hex: $(TARGET_HEX)

$(TARGET_HEX): $(TARGET_BIN)
	$(OBJCOPY) $(OBJ_COPY_FLAGS) $(TARGET_BIN) $(TARGET_HEX)

# Use the AVR-DUDE tool to flash the hex file onto the microcontroller
flash: $(TARGET_HEX)
	$(AVRDUDE) -F -V -c $(AVRDUDE_PROGRAMMER) -p $(ARCH) -P $(SERIAL_PORT) -b $(BAUD_RATE) -U flash:w:$(TARGET_HEX):i

# Remove all build artifacts
clean:
	sudo rm -rf $(TOPDIR)/target
