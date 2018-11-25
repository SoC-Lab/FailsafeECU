/*
 * Copyright:
 * ----------------------------------------------------------------
 * This confidential and proprietary software may be used only as
 * authorised by a licensing agreement from ARM Limited
 *   (C) COPYRIGHT 2014, 2016 ARM Limited
 *       ALL RIGHTS RESERVED
 * The entire notice above must be reproduced on all authorised
 * copies and copies may only be made to the extent permitted
 * by a licensing agreement from ARM Limited.
 * ----------------------------------------------------------------
 * File:     main.c
 * Release Information : Cortex-M1 DesignStart-r0p0-00rel0
 * ----------------------------------------------------------------
 *
 */

/*
 * --------Included Headers--------
 */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

// Xilinx specific headers
#include "xparameters.h"
#include "xgpio.h"

#include "m1_for_arty.h"        // Project specific header
#include "uart.h"

/*******************************************************************/

int main (void)
{
	// GPIO LED
	int status_LED;
	XGpio myGpio_LED;
	long long output; 
	output = 4294967295;
            
	status_LED = XGpio_Initialize(&myGpio_LED,XPAR_GPIO_0_DEVICE_ID);
	if (status_LED != XST_SUCCESS) {
		return XST_FAILURE;
	}
	
	XGpio_SetDataDirection(&myGpio_LED, 1,0x00); // all are outputs //Second Parameter is GPIO Channel
	XGpio_DiscreteWrite(&myGpio_LED, 1, 3); // void XGpio_DiscreteWrite(XGpio *InstancePtr, unsigned Channel, u32 Mask);
		
    
    while ( 1 )
    {
				
    
    }
}