#ifndef __MCU_H
#define __MCU_H

#include "packet.h"

typedef enum state_e 
{
    IDLE = 1,
    WAIT_FOR_ECU_DATA,
    SEND_ACK,
    SEND_ERROR,
} state_t;

void mcu_statemachine(double t_period_s);


#endif // __MCU_H