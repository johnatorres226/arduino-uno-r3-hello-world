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

clean:
	rm -f main.elf main.hex

.PHONY: all flash clean
