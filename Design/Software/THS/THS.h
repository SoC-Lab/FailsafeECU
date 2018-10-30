#ifndef __THS_H
#define __THS_H

#include "packet.h"

typedef enum state_e 
{
    IDLE = 1,
    WAIT_FOR_ECU_REQ,
    SEND_TH_POS,
    SEND_ERROR,
} state_t;

void ths_statemachine(double t_period_s);


#endif // __THS_H