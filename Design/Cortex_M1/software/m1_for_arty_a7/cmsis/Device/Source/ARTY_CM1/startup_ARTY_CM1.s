;/**************************************************************************//**
; * @file     startup_ARTY_CM1.s
; * @brief    CMSIS Core Device Startup File for
; *           CM1 Device
; * @version  V3.02
; * @date     18. April 2018
; *
; * @note
; *
; ******************************************************************************/
;/* Copyright (c) 2011 - 2018 ARM LIMITED
;
;   All rights reserved.
;   Redistribution and use in source and binary forms, with or without
;   modification, are permitted provided that the following conditions are met:
;   - Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;   - Redistributions in binary form must reproduce the above copyright
;     notice, this list of conditions and the following disclaimer in the
;     documentation and/or other materials provided with the distribution.
;   - Neither the name of ARM nor the names of its contributors may be used
;     to endorse or promote products derived from this software without
;     specific prior written permission.
;   *
;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;   ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS AND CONTRIBUTORS BE
;   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;   POSSIBILITY OF SUCH DAMAGE.
;   ---------------------------------------------------------------------------*/
;/*
;//-------- <<< Use Configuration Wizard in Context Menu >>> ------------------
;*/


; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00000400

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00000C00

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
                EXPORT  __Vectors_End
                EXPORT  __Vectors_Size

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                ; External Interrupts
                DCD     UART0_Handler             ; UART 0 Handler
                DCD     GPIO0_Handler             ; GPIO 0 Handler
                DCD     GPIO1_Handler             ; GPIO 1 Handler
                DCD     QSPI0_Handler             ; QUAD SPI 0 (Arty board) Handler
                DCD     DAP_QSPI0_Handler         ; DAPLink board QUAD SPI 0 Handler
                DCD     DAP_SPI0_Handler          ; DAPLink board SPI 0 Handler
                DCD     DAP_QSPI_XIP_Handler      ; DAPLink board QUAD SPI XIP Handler
                DCD     Unused_IRQ7               ; Unused
                DCD     Unused_IRQ8               ; Unused
                DCD     Unused_IRQ9               ; Unused
                DCD     Unused_IRQ10              ; Unused
                DCD     Unused_IRQ11              ; Unused
                DCD     Unused_IRQ12              ; Unused
                DCD     Unused_IRQ13              ; Unused
                DCD     Unused_IRQ14              ; Unused
                DCD     Unused_IRQ15              ; Unused
                DCD     Unused_IRQ16              ; Unused
                DCD     Unused_IRQ17              ; Unused
                DCD     Unused_IRQ18              ; Unused
                DCD     Unused_IRQ19              ; Unused
                DCD     Unused_IRQ20              ; Unused
                DCD     Unused_IRQ21              ; Unused
                DCD     Unused_IRQ22              ; Unused
                DCD     Unused_IRQ23              ; Unused
                DCD     Unused_IRQ24              ; Unused
                DCD     Unused_IRQ25              ; Unused
                DCD     Unused_IRQ26              ; Unused
                DCD     Unused_IRQ27              ; Unused
                DCD     Unused_IRQ28              ; Unused
                DCD     Unused_IRQ29              ; Unused
                DCD     Unused_IRQ30              ; Unused
                DCD     DAPLinkFittedn            ; Used as steady state GPIO input, not IRQ
__Vectors_End

__Vectors_Size  EQU     __Vectors_End - __Vectors

                AREA    |.text|, CODE, READONLY


; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
                IMPORT  SystemInit
                IMPORT  __main
                LDR     R0, =SystemInit
                BLX     R0
                LDR     R0, =__main
                BX      R0
                ENDP


; Dummy Exception Handlers (infinite loops which can be modified)

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
               EXPORT  SysTick_Handler            [WEAK]
               B       .
               ENDP

Default_Handler PROC
                EXPORT UART0_Handler              [WEAK]
                EXPORT GPIO0_Handler              [WEAK]
                EXPORT GPIO1_Handler              [WEAK]
                EXPORT QSPI0_Handler              [WEAK]
                EXPORT DAP_QSPI0_Handler          [WEAK]
                EXPORT DAP_SPI0_Handler           [WEAK]
                EXPORT DAP_QSPI_XIP_Handler       [WEAK]
                EXPORT Unused_IRQ7                [WEAK]
                EXPORT Unused_IRQ8                [WEAK]
                EXPORT Unused_IRQ9                [WEAK]
                EXPORT Unused_IRQ10               [WEAK]
                EXPORT Unused_IRQ11               [WEAK]
                EXPORT Unused_IRQ12               [WEAK]
                EXPORT Unused_IRQ13               [WEAK]
                EXPORT Unused_IRQ14               [WEAK]
                EXPORT Unused_IRQ15               [WEAK]
                EXPORT Unused_IRQ16               [WEAK]
                EXPORT Unused_IRQ17               [WEAK]
                EXPORT Unused_IRQ18               [WEAK]
                EXPORT Unused_IRQ19               [WEAK]
                EXPORT Unused_IRQ20               [WEAK]
                EXPORT Unused_IRQ21               [WEAK]
                EXPORT Unused_IRQ22               [WEAK]
                EXPORT Unused_IRQ23               [WEAK]
                EXPORT Unused_IRQ24               [WEAK]
                EXPORT Unused_IRQ25               [WEAK]
                EXPORT Unused_IRQ26               [WEAK]
                EXPORT Unused_IRQ27               [WEAK]
                EXPORT Unused_IRQ28               [WEAK]
                EXPORT Unused_IRQ29               [WEAK]
                EXPORT Unused_IRQ30               [WEAK]
                EXPORT DAPLinkFittedn             [WEAK]

UART0_Handler
GPIO0_Handler
GPIO1_Handler
QSPI0_Handler 
DAP_QSPI0_Handler 
DAP_SPI0_Handler  
DAP_QSPI_XIP_Handler 
Unused_IRQ7   
Unused_IRQ8   
Unused_IRQ9   
Unused_IRQ10  
Unused_IRQ11  
Unused_IRQ12  
Unused_IRQ13  
Unused_IRQ14  
Unused_IRQ15  
Unused_IRQ16  
Unused_IRQ17  
Unused_IRQ18  
Unused_IRQ19  
Unused_IRQ20  
Unused_IRQ21  
Unused_IRQ22  
Unused_IRQ23  
Unused_IRQ24  
Unused_IRQ25  
Unused_IRQ26  
Unused_IRQ27  
Unused_IRQ28  
Unused_IRQ29  
Unused_IRQ30  
DAPLinkFittedn  
                B       .

                ENDP


                ALIGN


; User Initial Stack & Heap

                IF      :DEF:__MICROLIB

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap

__user_initial_stackheap PROC
                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR
                ENDP

                ALIGN

                ENDIF


                END
