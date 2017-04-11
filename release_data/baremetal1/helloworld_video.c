//-----------------------------------------------------------------------------
// Function             : helloworld_video
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
#include "xvtc.h"
#include "xaxivdma.h"
#include "xil_cache.h"
#define GPIO_EXAMPLE_DEVICE_ID  XPAR_GPIO_0_DEVICE_ID
#define LED_CHANNEL 1
#define LED_DELAY     100000000
#define DMA_DEVICE_ID		XPAR_AXIVDMA_0_DEVICE_ID
#define XVTC_DEVICE_ID			XPAR_VTC_0_DEVICE_ID
#define DDR3_PTR      (*(volatile unsigned int *) 0x08000000 )
XGpio Gpio;
XVtc	VtcInst;
XAxiVdma AxiVdma;

int main()
{
	int i,v,h1;
	int Status;
	volatile int Delay;
	volatile unsigned char *ddr_ptr;
	//
	XVtc_Config *Config_vtc;
	XAxiVdma_Config *Config_Vdma;
    init_platform();
	print("Hello World¥n¥r");
    Xil_DCacheDisable();//キャッシュ無効
	//gpio
	Status = XGpio_Initialize(&Gpio, GPIO_EXAMPLE_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	//vtc
	Config_vtc = XVtc_LookupConfig(XVTC_DEVICE_ID);
	Status = XVtc_CfgInitialize(&VtcInst, Config_vtc, Config_vtc->BaseAddress);
	if (Status != (XST_SUCCESS)) {
		return (XST_FAILURE);
	}
	 XVtc_Enable(&VtcInst); //vtc start	 
	//dma
	Config_Vdma = XAxiVdma_LookupConfig(DMA_DEVICE_ID);
	if (!Config_Vdma){
			return XST_FAILURE;
	}
	Status = XAxiVdma_CfgInitialize(&AxiVdma, Config_Vdma, Config_Vdma->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	//dma設定
	XAxiVdma_WriteReg(XPAR_AXI_VDMA_0_BASEADDR, 0x0, 0x4); //reset
	XAxiVdma_WriteReg(XPAR_AXI_VDMA_0_BASEADDR, 0x0, 0x8); //gen-lock
	XAxiVdma_WriteReg(XPAR_AXI_VDMA_0_BASEADDR, 0x5C, 0x08000000);//start adr
	XAxiVdma_WriteReg(XPAR_AXI_VDMA_0_BASEADDR, 0x54, 1280*3);//h size
	XAxiVdma_WriteReg(XPAR_AXI_VDMA_0_BASEADDR, 0x58, 0x01001000);//
	XAxiVdma_WriteReg(XPAR_AXI_VDMA_0_BASEADDR, 0x0, 0x83);//enablr
	XAxiVdma_WriteReg(XPAR_AXI_VDMA_0_BASEADDR, 0x50, 720);//v size,start dma
    //LED制御および画像データ生成
    while(1){
    	for(i=0;i<4;i++){
    		XGpio_DiscreteWrite(&Gpio, LED_CHANNEL, (u32)i);
           for(v=0;v<720;v++){ //垂直方向カウント
              for(h1=0;h1<1280;h1++)//水平方向カウント
        	   {
     		      ddr_ptr = (unsigned char *) 0x08000000+(v*0x1000)+h1*3;
        		  if((i==0)||(i==3))
       	     	     *ddr_ptr = 0xff; //赤
        		  else
      	     	     *ddr_ptr = 0x0;
   			      ddr_ptr++;
   			      if((i==1)||(i==3))
       	     	        *ddr_ptr = 0xff;//緑
         		  else
       	     	     *ddr_ptr = 0x0;
   			       ddr_ptr++;
   			      if((i==2)||(i==3))
       	     	        *ddr_ptr = 0xff;//青
         		  else
       	     	     *ddr_ptr = 0x0;
        	   }
           }
           for(Delay=0;Delay<0x100000;Delay++);
    	}
    }
    cleanup_platform();
    return 0;
}
