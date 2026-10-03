MCU      = atmega328p
F_CPU    = 16000000UL
PORT     = /dev/cu.usbmodem*
BAUD     = 115200

CC       = avr-gcc
OBJCOPY  = avr-objcopy
CFLAGS   = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os -std=c11 -Wall

all: main.hex

main.elf: main.c
	$(CC) $(CFLAGS) -o $@ $<

main.hex: main.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

flash: main.hex
	avrdude -c arduino -p $(MCU) -P $(PORT) -b $(BAUD) -U flash:w:$<:i

# make blank: "wipe" the board by replacing the blink program with one
# that does nothing.
#
# Why not `avrdude -e` (chip erase)? The UNO is flashed through Optiboot, a
# small bootloader already living on the chip. Optiboot can only write new
# program data; it has no erase command, so -e would silently do nothing.
# Overwriting the old program with an empty one has the same visible effect
# and leaves the bootloader intact, so USB uploads keep working.
#
# Steps:
#   1. Compile a one-line C program (an endless empty loop) straight from
#      the shell, no source file needed. `-x c -` means "C code from stdin".
#   2. Convert the result into a .hex file, the format avrdude uploads.
#   3. Upload it, replacing whatever was on the board (e.g. the blink).
blank:
	echo 'int main(void){for(;;);}' | $(CC) -mmcu=$(MCU) -Os -x c -o blank.elf -
	$(OBJCOPY) -O ihex -R .eeprom blank.elf blank.hex
	avrdude -c arduino -p $(MCU) -P $(PORT) -b $(BAUD) -U flash:w:blank.hex:i

clean:
	rm -f main.elf main.hex blank.elf blank.hex

.PHONY: all flash blank clean
