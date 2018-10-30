#include "MCU.h"

void mcu_statemachine(double t_period_s)
{
    static uint8_t ini_ok = 0;
    static state_t state;
    static state_t m_state;
    static double  t;
    static unit8_t tx_data;
    static uint8_t motor_param;

    /*** input process image ***/
    const uint8_t rx_data = can_receive();
    const uint8_t error = get_error();

    /*** processing ***/
    do
    {
        if(!ini_ok)               { t = 0;              }
        else if(state != m_state) { t = 0;              }
        else                      { t = t + t_period_s; }

        m_state = state;

        if(!ini_ok) { 
            state = IDLE;
            m_state = state;    
        }
        else if(state != IDLE && t > 0 && error != 0) {
            tx_data = build_control_packet(ECU_ID, MCU_ID, ERROR_2);
            state = SEND_ERROR;
        }
        else if(state == IDLE && t > 0 && validate_data_packet(MCU_ID, rx_data)) {
            state = WAIT_FOR_ECU_DATA;
        }
        else if(state == WAIT_FOR_ECU_DATA && t > 0 && validate_control_packet(ECU_ID, MCU_ID, ACKNOWLEDGE, rx_data)) {
            state = IDLE;
        }
        else if(state == WAIT_FOR_ECU_DATA && t > 0 && validate_data_packet(MCU_ID, rx_data)) {
            tx_data = build_control_packet(ECU_ID, MCU_ID, ACKNOWLEDGE);
            state = SEND_ACK;
        }
        else if(state == SEND_ACK && t > 0) {
            state = WAIT_FOR_ECU_DATA;
        }
        else if(state == SEND_ERROR && t > 0) {
            state = IDLE;
        }
        // else;
    } while(state != m_state);

    /*** output process image ***/
    if(!ini_ok);
    else if(state == SEND_ACK) { 
        set_motor_param(rx_data & DATA_MASK); 
        can_send(tx_data);
    }
    else if(state == SEND_ERROR) { 
        can_send(tx_data);                                    
    }
    // else;

    ini_ok = 1;
}
