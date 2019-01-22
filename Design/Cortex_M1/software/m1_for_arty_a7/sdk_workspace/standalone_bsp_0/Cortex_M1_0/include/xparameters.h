#ifndef XPARAMETERS_H   /* prevent circular inclusions */
#define XPARAMETERS_H   /* by using protection macros */

/* Definition for CPU ID */
#define XPAR_CPU_ID 0U

/* Definitions for peripheral CORTEX_M1_0 */
#define XPAR_CORTEX_M1_0_CPU_CLK_FREQ_HZ 0


/******************************************************************/

/* Canonical definitions for peripheral CORTEX_M1_0 */
#define XPAR_CPU_CORTEXM1_0_CPU_CLK_FREQ_HZ 0


/******************************************************************/


/******************************************************************/

/* Platform specific definitions */
#define PLATFORM_ARM
 
/* Definitions for sleep timer configuration */
#define XSLEEP_TIMER_IS_DEFAULT_TIMER
 
 
/******************************************************************/
/* Definitions for driver BRAM */
#define XPAR_XBRAM_NUM_INSTANCES 1U

/* Definitions for peripheral AXI_BRAM_CTRL_0 */
#define XPAR_AXI_BRAM_CTRL_0_DEVICE_ID 0U
#define XPAR_AXI_BRAM_CTRL_0_DATA_WIDTH 32U
#define XPAR_AXI_BRAM_CTRL_0_ECC 0U
#define XPAR_AXI_BRAM_CTRL_0_FAULT_INJECT 0U
#define XPAR_AXI_BRAM_CTRL_0_CE_FAILING_REGISTERS 0U
#define XPAR_AXI_BRAM_CTRL_0_UE_FAILING_REGISTERS 0U
#define XPAR_AXI_BRAM_CTRL_0_ECC_STATUS_REGISTERS 0U
#define XPAR_AXI_BRAM_CTRL_0_CE_COUNTER_WIDTH 0U
#define XPAR_AXI_BRAM_CTRL_0_ECC_ONOFF_REGISTER 0U
#define XPAR_AXI_BRAM_CTRL_0_ECC_ONOFF_RESET_VALUE 0U
#define XPAR_AXI_BRAM_CTRL_0_WRITE_ACCESS 0U
#define XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR 0xC0000000U
#define XPAR_AXI_BRAM_CTRL_0_S_AXI_HIGHADDR 0xC000FFFFU
#define XPAR_AXI_BRAM_CTRL_0_S_AXI_CTRL_BASEADDR 0xFFFFFFFFU 
#define XPAR_AXI_BRAM_CTRL_0_S_AXI_CTRL_HIGHADDR 0xFFFFFFFFU 


/******************************************************************/

/* Canonical definitions for peripheral AXI_BRAM_CTRL_0 */
#define XPAR_BRAM_0_DEVICE_ID XPAR_AXI_BRAM_CTRL_0_DEVICE_ID
#define XPAR_BRAM_0_DATA_WIDTH 32U
#define XPAR_BRAM_0_ECC 0U
#define XPAR_BRAM_0_FAULT_INJECT 0U
#define XPAR_BRAM_0_CE_FAILING_REGISTERS 0U
#define XPAR_BRAM_0_UE_FAILING_REGISTERS 0U
#define XPAR_BRAM_0_ECC_STATUS_REGISTERS 0U
#define XPAR_BRAM_0_CE_COUNTER_WIDTH 0U
#define XPAR_BRAM_0_ECC_ONOFF_REGISTER 0U
#define XPAR_BRAM_0_ECC_ONOFF_RESET_VALUE 0U
#define XPAR_BRAM_0_WRITE_ACCESS 0U
#define XPAR_BRAM_0_BASEADDR 0xC0000000U
#define XPAR_BRAM_0_HIGHADDR 0xC000FFFFU


/******************************************************************/

/* Definitions for driver GPIO */
#define XPAR_XGPIO_NUM_INSTANCES 1

/* Definitions for peripheral AXI_GPIO_2 */
#define XPAR_AXI_GPIO_2_BASEADDR 0x40000000
#define XPAR_AXI_GPIO_2_HIGHADDR 0x4000FFFF
#define XPAR_AXI_GPIO_2_DEVICE_ID 0
#define XPAR_AXI_GPIO_2_INTERRUPT_PRESENT 0
#define XPAR_AXI_GPIO_2_IS_DUAL 0


/******************************************************************/

/* Canonical definitions for peripheral AXI_GPIO_2 */
#define XPAR_GPIO_0_BASEADDR 0x40000000
#define XPAR_GPIO_0_HIGHADDR 0x4000FFFF
#define XPAR_GPIO_0_DEVICE_ID XPAR_AXI_GPIO_2_DEVICE_ID
#define XPAR_GPIO_0_INTERRUPT_PRESENT 0
#define XPAR_GPIO_0_IS_DUAL 0


/******************************************************************/

/* Definitions for driver UARTLITE */
#define XPAR_XUARTLITE_NUM_INSTANCES 1

/* Definitions for peripheral AXI_UARTLITE_0 */
#define XPAR_AXI_UARTLITE_0_BASEADDR 0x40100000
#define XPAR_AXI_UARTLITE_0_HIGHADDR 0x4010FFFF
#define XPAR_AXI_UARTLITE_0_DEVICE_ID 0
#define XPAR_AXI_UARTLITE_0_BAUDRATE 115200
#define XPAR_AXI_UARTLITE_0_USE_PARITY 0
#define XPAR_AXI_UARTLITE_0_ODD_PARITY 0
#define XPAR_AXI_UARTLITE_0_DATA_BITS 8


/******************************************************************/

/* Canonical definitions for peripheral AXI_UARTLITE_0 */
#define XPAR_UARTLITE_0_DEVICE_ID XPAR_AXI_UARTLITE_0_DEVICE_ID
#define XPAR_UARTLITE_0_BASEADDR 0x40100000
#define XPAR_UARTLITE_0_HIGHADDR 0x4010FFFF
#define XPAR_UARTLITE_0_BAUDRATE 115200
#define XPAR_UARTLITE_0_USE_PARITY 0
#define XPAR_UARTLITE_0_ODD_PARITY 0
#define XPAR_UARTLITE_0_DATA_BITS 8


/******************************************************************/

#endif  /* end of protection macro */
