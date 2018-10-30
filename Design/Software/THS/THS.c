#include "THS.h"

void ths_statemachine(double t_period_s)
{
    static uint8_t ini_ok = 0;
    static state_t state;
    static state_t m_state;
    static double  t;
    static unit8_t tx_data;

    /*** input process image ***/
    const uint8_t rx_data = can_receive();
    const uint8_t throttle_pos = read_th_pos();
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
            tx_data = build_control_packet(ECU_ID, THS_ID, ERROR_1);
            state = SEND_ERROR;
        }
        else if(state == IDLE && t > 0 && validate_control_packet(THS_ID, ECU_ID, REQUEST, rx_data)) {
            state = WAIT_FOR_ECU_REQ;
        }
        else if(state == WAIT_FOR_ECU_REQ && t > 0 && validate_data_packet(THS_ID, rx_data)) {
            state = IDLE;
        }
        else if(state == WAIT_FOR_ECU_REQ && t > 0 && validate_control_packet(THS_ID, ECU_ID, REQUEST, rx_data)) {
            tx_data = build_data_packet(ECU_ID, throttle_pos);
            state = SEND_TH_POS;
        }
        else if(state == SEND_TH_POS && t > 0) {
            state = WAIT_FOR_ECU_REQ;
        }
        else if(state == SEND_ERROR && t > 0) {
            state = IDLE;
        }
        // else;
    } while(state != m_state);

    /*** output process image ***/
    if(!ini_ok);
    else if(state == SEND_TH_POS) { can_send(tx_data); }
    else if(state == SEND_ERROR)  { can_send(tx_data); }
    // else;

    ini_ok = 1;
}
