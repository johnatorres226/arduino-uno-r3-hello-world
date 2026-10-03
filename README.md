# Hello World: UNO R3, Pure C

Blinks the onboard LED on an Elegoo/Arduino UNO R3, written in plain C
(no Arduino framework, no `.ino`, no `setup()`/`loop()`).

## Introduction

An Arduino is a tiny computer board. Normally, people write code for it
using a beginner-friendly toolkit called the "Arduino language," which
hides a lot of the hard stuff.

We're doing it the harder, more direct way: writing real C code, the same
language used for a lot of professional and embedded software. That means
we talk to the chip's memory switches directly instead of using easy
helper commands like `digitalWrite()`.

**What the program does:** it turns the little LED on the board on, then
off, then on, then off, forever, about twice as fast as a heartbeat.
That's the classic "hello world" for hardware: if the light blinks,
everything worked. You can watch a 3 second clip of it running in
[examples/250ms display.mov](examples/250ms%20display.mov).

**Why we had to install extra tools:** computers don't speak "chip
language" by default, so we installed two programs:
- **avrdude** copies our finished code onto the Arduino over the USB
  cable.
- **avr-gcc** is a special version of a C compiler (a program that turns
  human-written code into the 1s and 0s a chip understands) built
  specifically for the tiny chip inside the UNO R3.

**The outcome:** once both tools are installed, one command turns
`main.c` into a file the Arduino can run, and a second command sends it
over USB. Plug in the board, run the commands, and watch the LED blink.

## Technical details

- **Target:** the ATmega328P, the **MCU** (microcontroller unit) soldered
  onto the UNO R3. It's the single chip that acts as the whole "computer"
  on the board, with the processor, memory, and pins all in one. It runs
  at **16 MHz**, which means its clock ticks 16 million times per second.
  Each tick is a chance for the chip to execute a step of your program, so
  16 MHz is roughly its top speed. For comparison, a laptop CPU runs at a
  few *billion* ticks per second. This chip is small and slow on purpose,
  trading speed for cost and simplicity.
- **`main.c`:** the ATmega328P controls its pins through **registers**,
  which are named memory locations wired directly to hardware. Flipping a
  bit in a register flips a real physical pin. `DDRB` ("Data Direction
  Register B") decides, pin by pin, whether each pin on port B is an input
  or an output. Setting bit 5 makes Arduino pin 13 (PB5, the onboard LED)
  an output. `PORTB` then holds the actual on/off value of those pins, so
  toggling its bit 5 flips the LED. The program does that toggle in an
  infinite loop with a 250 ms `_delay_ms()` pause between toggles. There's
  no Arduino core and no `.ino` preprocessing, so this compiles as
  standard C11 against `avr-libc`.
- **Toolchain:**
  - `avr-gcc` cross-compiles `main.c` for the AVR instruction set, since
    your Mac's native compiler targets x86/ARM, not AVR. It comes from the
    `osx-cross/avr` Homebrew tap because Homebrew dropped it from
    homebrew-core.
  - `avr-libc` comes along with avr-gcc and provides `<avr/io.h>` and
    `<util/delay.h>`, the register names and delay routines.
  - `avrdude` flashes the resulting `.hex` file to the board through the
    UNO's USB-serial bootloader.
- **Build artifacts:** `main.c` is compiled into `main.elf` (the linked
  binary), which is converted into `main.hex` (the Intel HEX format that
  avrdude and the bootloader expect).

### Build & flash

```sh
make          # produces main.hex
make flash    # uploads main.hex to the board (adjust PORT in Makefile if needed)
```

Check your board's serial port with `ls /dev/cu.usbmodem*` and update
the `PORT` variable in the `Makefile` if it doesn't match.

### Wiping the board

Once flashed, the board runs the blink every time it's powered on. To
stop that:

```sh
make blank    # replaces the blink with a program that does nothing
make flash    # puts the blink back
```

You might expect `avrdude -e` (chip erase) to do this, but it won't work
here. The UNO is flashed through a small bootloader called Optiboot that
already lives on the chip. Optiboot can write new programs but has no
erase command, so `-e` quietly does nothing. Overwriting the blink with an
empty program looks the same from the outside, and it leaves the
bootloader alone so USB uploads keep working.

`make blank` compiles a one-line empty program, turns it into a `.hex`
file, and uploads it the same way `make flash` does. The comments in the
`Makefile` walk through each step.
