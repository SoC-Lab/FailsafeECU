#include "mbed.h"
#include "ECU.h"

//------------------------------------
// Hyperterminal configuration
// 9600 bauds, 8-bit data, no parity
//------------------------------------

Serial pc(SERIAL_TX, SERIAL_RX);
volatile char   c = '\0'; // Initialized to the NULL character

DigitalOut myled(LED1);

void onCharReceived()
{
    c = pc.getc();
}

int main()
{
	pc.attach(&onCharReceived);

    int i = 1;
    pc.printf("Hello World !\n");
    while(1) {
        wait(1);
        pc.printf("This program runs since %d seconds.\n", i++);

        myled = !myled;
        c = pc.getc();
    }
}
