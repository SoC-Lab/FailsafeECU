#ifndef __ECU_H
#define __ECU_H

#include "packet.h"

typedef enum state_e 
{
    START = 1,
    REQUEST_TH_POS,
    RECEIVE_TH_POS,
    CALC_MOTOR_PAR,
    SEND_MOTOR_PAR,
    WAIT_FOR_MCU_ACK,
} state_t;

void ecu_statemachine(double t_period_s);


#endif // __ECU_H