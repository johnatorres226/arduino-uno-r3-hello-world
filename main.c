/*
 * Blink the onboard LED on an Arduino UNO R3 using plain C.
 * No Arduino library: we flip the chip's hardware registers directly.
 */

#include <avr/io.h>     /* register names: DDRB, PORTB, PB5, ... */
#include <util/delay.h> /* _delay_ms(); needs F_CPU (set in the Makefile) */

/* The LED is wired to pin PB5 (bit 5 of port B), which the board labels
 * "pin 13". */
#define LED_PIN PB5

int main(void) {
    /* DDRB = Data Direction Register B. One bit per pin on port B:
     * 1 = output, 0 = input. Pins start as inputs, so set bit 5 to make
     * the LED pin an output. `|=` changes only that bit and leaves the
     * other pins alone. */
    DDRB |= (1 << LED_PIN);

    /* Loop forever: a microcontroller has no operating system to return
     * to, so main() must never end. */
    while (1) {
        /* PORTB holds the on/off value of each output pin on port B
         * (1 = on/5V, 0 = off/0V). `^=` (XOR) flips just the LED bit:
         * on becomes off, off becomes on. */
        PORTB ^= (1 << LED_PIN);

        /* Wait 250 ms (busy-waiting), so each on or off state lasts a
         * quarter second. */
        _delay_ms(250);
    }
}
