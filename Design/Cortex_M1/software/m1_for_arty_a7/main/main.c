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

    // Define local variables
    int     status;
    int     DAPLinkFittedn;
    int     i;
    int     readbackError;
    char    debugStr[256];
    
    // Illegal location
    volatile u32 emptyLoc;
    volatile u32 QSPIbase;
    
    // BRAM base
    // Specify as volatile to ensure processor reads values back from BRAM
    // and not local storage
    volatile u32 *pBRAMmemory = (u32 *)XPAR_BRAM_0_BASEADDR;

    // CPU ID register
    volatile u32 *pCPUId = (u32 *)0xE000ED00;
    volatile u32 CPUId;
    int          CPU_part;
    int          CPU_rev;
    int          CPU_var;
    char         CPU_name[20];
		
		// Test data for SPI
    u8 spi_tx_data[8] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef};
    u8 spi_rx_data[8] = {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
    
    // Test data for BRAM
    u32 bram_data[8] = {0x01234567, 0x89abcdef, 0xdeadbeef, 0xfeebdaed, 0xa5f03ca5, 0x87654321, 0xfedc0ba9, 0x01020408};
		
		// GPIO LED
		int status_LED;
		XGpio myGpio_LED;
		u32 output; 
		output = 4294967295;
        

    // init_platform is defined in platform.c
    // It calls enable_caches which is uBlaze specific and then init_uart
//    init_platform();
//    init_uart();
    InitialiseUART();
  

    // Clear all interrupts
    NVIC_ClearAllPendingIRQ();
    

		
	status_LED = XGpio_Initialize(&myGpio_LED,XPAR_GPIO_0_DEVICE_ID);
	if (status_LED != XST_SUCCESS) {
		return XST_FAILURE;
	}
	
	XGpio_SetDataDirection(&myGpio_LED, 1,0x00); // all are outputs //Second Parameter is GPIO Channel
	XGpio_DiscreteWrite(&myGpio_LED, 1, output);
		
    // Enable the UART interrupt
    NVIC_EnableIRQ(UART0_IRQn);
    NVIC_EnableIRQ(GPIO0_IRQn);
    NVIC_EnableIRQ(GPIO1_IRQn);


    // Enable UART Interrupts
    EnableUARTInterrupts();

    // Read the CPU ID register to auto-detect the CPU and revision
    // Note however that code is compiled for a specific processor, so even though
    // the processor can be auto-detected, if the compiled code has extended commands not
    // supported by the processor, then runtime issues can occur
    CPUId    = *pCPUId;
    CPU_var  = ((CPUId & 0x00F00000) >> 20);
    CPU_part = ((CPUId & 0x0000FFF0) >> 4);
    CPU_rev  = CPUId & (0x0000000F);
    
    switch (CPU_part)
    {
        case 0xC21 : strcpy(  CPU_name, "Cortex-M1" ); break;
        case 0xC23 : strcpy(  CPU_name, "Cortex-M3" ); break;
        default    : sprintf( CPU_name, "Unknown %x", CPU_part );
    }
    
    // *****************************************************
    // Test the BRAM
    // *****************************************************

    // Write to BRAM
    for( i=0; i< (sizeof(bram_data)/sizeof(u32)); i++)
        *pBRAMmemory++ = bram_data[i];
    
    readbackError = 0;
    // Reset the pointer
    pBRAMmemory = (u32 *)XPAR_BRAM_0_BASEADDR;

    // Readback
    for( i=0; i< (sizeof(bram_data)/sizeof(u32)); i++)
    {
        if ( *pBRAMmemory++ != bram_data[i] )
            readbackError++;
    }





    // ******************************************************
    // Test exceptions.  Write to legal and illegal addresses
    // ******************************************************
/*    
    // Do an access to an legal location
    emptyLoc = *pLegalAddr;

    // Do an access to an illegal location
    emptyLoc = *pIllegalAddr;

*/


    // Main loop.  Handle LEDs and switches via interrupt
    while ( 1 )
    {

    
    }
}

/* Interrupt handler for DAPLink Fitted */
// This routine should never be called as the signal is used as IO
// Routine created to prevent exceptions in the case the IRQ is enabled
void DAPLinkFittedn ( void )
{
    // Clear the IRQ and disable any future IRQs
    NVIC_ClearPendingIRQ(DAPLinkFittedn_IRQn);
    NVIC_DisableIRQ(DAPLinkFittedn_IRQn);
}
