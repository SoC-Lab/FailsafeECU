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

uint8_t LED_val = 0; // Value will be toggled for making the LED's Blink
XGpio myGpio_LED; // GPIO IP Control

void SysTick_Handler(void)  {  /* SysTick interrupt Handler. */
	XGpio_DiscreteWrite(&myGpio_LED, 1, LED_val); // void XGpio_DiscreteWrite(XGpio *InstancePtr, unsigned Channel, u32 Mask);
	LED_val = ~LED_val; // bitwise NOT
}

int main (void)
{
	uint32_t status_sysTick;
	uint32_t status_LED;


// Configure System Tick Timer	
	status_sysTick = SysTick_Config(SystemCoreClock); // Change the frequency of SysTick interrupts
	
	status_LED = XGpio_Initialize(&myGpio_LED,XPAR_GPIO_0_DEVICE_ID);// Required Initialization
	if (status_LED != XST_SUCCESS) {
		return XST_FAILURE;
	}
	
	XGpio_SetDataDirection(&myGpio_LED, 1,0x00); // all GPIO's are outputsSecond Parameter is GPIO Channel
    
    while ( 1 )
    {
    
    }
}

// Configure System Tick Timer with Registers Cortex-M1 Specific
//  volatile u32 *pSystick_CSR = (u32 *)0xE000E010; // SysTick Control and Status Register
//	volatile u32 *pSystick_RVR = (u32 *)0xE000E014; // SysTick Reload Value Register
//	volatile u32 *pSystick_CVR = (u32 *)0xE000E018; // SysTick Current Value Register
