//*****************************************************************************
// File Name            : helloworld_gpio.c
//-----------------------------------------------------------------------------
// Function             : helloworld_gpio
//
//-----------------------------------------------------------------------------
// Designer             : yokomizo
//-----------------------------------------------------------------------------
// History
// -.-- 2015/07/29
//*****************************************************************************

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xgpio.h"
#define LED_DELAY     100000000
XGpio Gpio;

int main()
{
int i;
volatile int Delay;
int Status;
    init_platform();
    print("Hello World\n\r");

    //GPIO init
	Status = XGpio_Initialize(&Gpio, XPAR_GPIO_0_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
    while(1){
    	for(i=0;i<16;i++){
    		XGpio_DiscreteWrite(&Gpio,1, (u32)i);//LED“_“”
    		for(Delay=0;Delay<LED_DELAY ;Delay++);
    	}
    }
    cleanup_platform();
    return 0;
}
