#include <avr/io.h>
#include <util/delay.h>

int main(void) {
    // Set PORTB5 as output
    DDRB |= (1 << PORTB5);

    // forever...
    while (1)
    {
        // toggle PORTB5
        PORTB ^= (1 << PORTB5);

        // wait 1 second
        _delay_ms(1000);
    }
}
