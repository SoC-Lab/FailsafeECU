#include "mbed.h"
#include "ECU.h"

//------------------------------------
// Hyperterminal configuration
// 9600 bauds, 8-bit data, no parity
//------------------------------------

RawSerial serial(PA_9, PA_10);

DigitalOut myled(LED1);

const float intervall_s = 0.1;

int main()
{
	while(1) {

		ecu_statemachine(intervall_s, &serial);

        wait(intervall_s * 1000);

        myled = !myled;
    }
}
