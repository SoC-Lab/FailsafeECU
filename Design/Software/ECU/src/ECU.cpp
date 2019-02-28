#include "ECU.h"
#include "packet.h"

void ecu_statemachine(double t_period_s, RawSerial* serial)
{
    static uint8_t ini_ok = 0;
    static state_t state;
    static state_t m_state;
    static double  t;
    static uint8_t throttle_pos;
    static uint8_t tx_data;
    static uint8_t attempt;
    static uint8_t motor_par;

    /*** input process image ***/
    const uint8_t rx_data = serial->getc();

    /*** processing ***/
    do
    {
        if(!ini_ok)               { t = 0;              }
        else if(state != m_state) { t = 0;              }
        else                      { t = t + t_period_s; }

        m_state = state;

        if(!ini_ok) { 
            state = START;
            m_state = state;
            attempt = 0;   
            throttle_pos = 0;
            motor_par = 0;
            tx_data = 0;             
        }
        else if(state == START && t > 0) {
            attempt = 1; 
            tx_data = build_control_packet(THS_ID, ECU_ID, REQUEST); 
            state = REQUEST_TH_POS; 
        }
        else if(state == REQUEST_TH_POS && t > 0) { 
            state = RECEIVE_TH_POS;  
        }
        else if(state == RECEIVE_TH_POS && t > 0 && validate_data_packet(ECU_ID, rx_data)) { 
            attempt = 1; 
            throttle_pos = rx_data & DATA_MASK; 
            state = CALC_MOTOR_PAR; 
        }
        else if(state == RECEIVE_TH_POS && t > TIMEOUT_S && attempt < 4) {  
            attempt++; 
            tx_data = build_control_packet(THS_ID, ECU_ID, REQUEST); 
            state = REQUEST_TH_POS;
        }
        else if(state == CALC_MOTOR_PAR && t > 0) {
            motor_par = throttle_pos;
            tx_data = build_data_packet(MCU_ID, motor_par);
            state = SEND_MOTOR_PAR;
        }
        else if(state == SEND_MOTOR_PAR && t > 0) { 
            state = WAIT_FOR_MCU_ACK;  
        }
        else if(state == WAIT_FOR_MCU_ACK && t > 0 && validate_control_packet(ECU_ID, MCU_ID, ACKNOWLEDGE, rx_data)) { 
            state = REQUEST_TH_POS; 
        }
        else if(state == WAIT_FOR_MCU_ACK && t > TIMEOUT_S && attempt < 4) { 
            attempt++; 
            tx_data = build_data_packet(MCU_ID, throttle_pos);
            state = SEND_MOTOR_PAR;                    
        }
        // else;
    } while(state != m_state);

    /*** output process image ***/
    if(!ini_ok);
    else if(state == REQUEST_TH_POS) { 
    	serial->putc(tx_data);
    }
    else if(state == SEND_MOTOR_PAR) { 
    	serial->putc(tx_data);
    }
    // else;

    ini_ok = 1;
}
