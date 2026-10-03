# Hello World — UNO R3, Pure C

Blinks the onboard LED on an Elegoo/Arduino UNO R3, written in plain C
(no Arduino framework, no `.ino`, no `setup()`/`loop()`).

## Introduction

An Arduino is a tiny computer board. Normally, people write code for it
using a beginner-friendly toolkit called the "Arduino language," which
hides a lot of the hard stuff.

We're doing it the harder, more direct way: writing real C code, the same
language used for a lot of professional and embedded software. This means
we talk to the chip's memory switches directly instead of using easy
helper commands like `digitalWrite()`.

**What the program does:** it turns the little LED on the board on, then
off, then on, then off — forever — about twice as fast as a heartbeat.
That's the classic "hello world" for hardware: if the light blinks,
everything worked.

**Why we had to install extra tools:** computers doesn't speak
"chip language" by default. We install:
- **avrdude** — a program that copies our finished code onto the Arduino
  over the USB cable.
- **avr-gcc** — a special version of a C compiler (a program that turns
  human-written code into the 1s and 0s a chip understands) built
  specifically for the tiny chip inside the UNO R3.

**The outcome:** once both tools are installed, running one command
turns `main.c` into a file the Arduino can run, and a second command
sends it over USB. Plug in the board, run the commands, watch the LED
blink.

## Technical details

- **Target:** the ATmega328P — the **MCU** (microcontroller unit, the
  single chip that is the whole "computer" on the board: processor,
  memory, and pins, all in one) soldered onto the UNO R3. It runs at
  **16 MHz**, meaning its clock ticks 16 million times per second — each
  tick is a chance for the chip to execute a step of your program, so
  16 MHz is roughly its top processing speed. (For comparison, a laptop
  CPU runs at a few *billion* ticks per second — this chip is small and
  slow on purpose, trading speed for cost and simplicity.)
- **`main.c`:** the ATmega328P controls its pins through **registers** —
  named memory locations that map directly to hardware, where flipping
  a bit flips a real physical pin. `DDRB` ("Data Direction Register B")
  picks, pin by pin, whether each pin on port B is an input or an
  output; setting bit 5 makes Arduino pin 13 / PB5 (the onboard LED) an
  output. `PORTB` then holds the actual on/off value of those pins;
  toggling its bit 5 flips the LED. The program does that toggle in an
  infinite loop with a 250 ms `_delay_ms()` pause between toggles. No
  Arduino core, no `.ino` preprocessing — this compiles as standard C11
  against `avr-libc`.
- **Toolchain:**
  - `avr-gcc` (from the `osx-cross/avr` Homebrew tap — Homebrew dropped
    `avr-gcc` from homebrew-core) cross-compiles `main.c` for the AVR
    instruction set, since your Mac's native compiler targets x86/ARM,
    not AVR.
  - `avr-libc` (pulled in with avr-gcc) provides `<avr/io.h>` and
    `<util/delay.h>`, the register-name macros and delay routines.
  - `avrdude` flashes the resulting `.hex` file to the board over the
    UNO's USB-serial bootloader.
- **Build artifacts:** `main.c` → `main.elf` (linked binary) →
  `main.hex` (Intel HEX format avrdude/the bootloader expects).

### Build & flash

```sh
make          # produces main.hex
make flash    # uploads main.hex to the board (adjust PORT in Makefile if needed)
```

Check your board's serial port with `ls /dev/cu.usbmodem*` and update
the `PORT` variable in the `Makefile` if it doesn't match.
