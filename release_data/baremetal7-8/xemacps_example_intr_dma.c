/******************************************************************************
*
* Copyright (C) 2010 - 2015 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/
/****************************************************************************/
/**
*
* @file xemacps_example_intr_dma.c
*
* Implements examples that utilize the EmacPs's interrupt driven DMA
* packet transfer mode to send and receive frames.
*
* These examples demonstrate:
*
* - How to perform simple send and receive.
* - Interrupt
* - Error handling
* - Device reset
*
* Functional guide to example:
*
* - EmacPsDmaSingleFrameIntrExample demonstrates the simplest way to send and
*   receive frames in in interrupt driven DMA mode.
*
* - EmacPsErrorHandler() demonstrates how to manage asynchronous errors.
*
* - EmacPsResetDevice() demonstrates how to reset the driver/HW without
*   loosing all configuration settings.
*
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a wsy  01/10/10 First release
* 1.00a asa  11/25/11 The cache disable routines are removed. So now both
*		      I-cache and D-cache are enabled. The array RxBuffer is
*		      removed to avoid an extra copy from RxBuffer to RxFrame.
*		      Now the address of RxFrame is submitted to the Rx BD
*		      instead of the address of RxBuffer.
*		      In function EmacPsDmaSingleFrameIntrExample, BdRxPtr
*		      is made as a pointer instead of array of pointers. This
*		      is done since on the Rx path we now submit a single BD
*		      instead of all 32 BDs. Because of this change, relevant
*		      changes are made throughout the function
*		      EmacPsDmaSingleFrameIntrExample.
*		      Cache invalidation is now being done for the RxFrame
*		      buffer.
*		      The unnecessary cache flush (Xil_DCacheFlushRange) is
*		      removed. This was being done towards the end of the
*		      example which was unnecessary.
* 1.00a asa 01/24/12  Support for Zynq board is added. The SLCR divisors are
* 		      different for Zynq. Changes are made for the same.
* 		      Presently the SLCR GEM clock divisors are hard-coded
*		      assuming that IO PLL output frequency is 1000 MHz.
* 		      The BDs are allocated at the address 0xFF00000 and the
* 		      1 MB address range starting from this address is made
* 		      uncached. This is because, for GEM the BDs need to be
* 		      placed in uncached memory. The RX BDs are allocated at
* 		      address 0xFF00000 and TX BDs are allocated at address
* 		      0xFF10000.
* 		      The MDIO divisor used of 224 is used for Zynq board.
* 1.01a asa 02/27/12  The hardcoded SLCR divisors for Zynq are removed. The
*		      divisors are obtained from xparameters.h.c. The sleep
*		      values are reduced for Zynq. One sleep is added after
*		      MDIO divisor is set. Some of the prints are removed.
* 1.01a asa 03/14/12  The SLCR divisor support for ENET1 is added.
* 1.01a asa 04/15/12  The funcation calls to Xil_DisableMMU and Xil_EnableMMU
*		      are removed for setting the translation table
*		      attributes for the BD memory region.
* 1.05a asa 09/22/13 Cache handling is changed to fix an issue (CR#663885).
*			  The cache invalidation of the Rx frame is now moved to
*			  XEmacPsRecvHandler so that invalidation happens after the
*			  received data is available in the memory. The variable
*			  TxFrameLength is now made global.
* 2.1	srt 07/11/14 Implemented 64-bit changes and modified as per
*		      Zynq Ultrascale Mp GEM specification
* 3.0  kpc  01/23/14 Removed PEEP board related code
* 3.0  hk   03/18/15 Added support for jumbo frames.
*                    Add cache flush after BD terminate entries.
*
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/
#include "xemacps_example.h"
#include "xil_exception.h"
#include "xil_mmu.h"
//cq add
#include "xil_mmu.h"
//#include "xil_types.h"

/*************************** Constant Definitions ***************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define EMACPS_DEVICE_ID	XPAR_XEMACPS_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID
#define EMACPS_IRPT_INTR	XPS_GEM0_INT_ID

#define RXBD_CNT       32	/* Number of RxBDs to use */
#define TXBD_CNT       32	/* Number of TxBDs to use */

/*
 * SLCR setting
 */
#define SLCR_LOCK_ADDR			(XPS_SYS_CTRL_BASEADDR + 0x4)
#define SLCR_UNLOCK_ADDR		(XPS_SYS_CTRL_BASEADDR + 0x8)
#define SLCR_GEM0_CLK_CTRL_ADDR		(XPS_SYS_CTRL_BASEADDR + 0x140)
#define SLCR_GEM1_CLK_CTRL_ADDR		(XPS_SYS_CTRL_BASEADDR + 0x144)


#define SLCR_LOCK_KEY_VALUE		0x767B
#define SLCR_UNLOCK_KEY_VALUE		0xDF0D
#define SLCR_ADDR_GEM_RST_CTRL		(XPS_SYS_CTRL_BASEADDR + 0x214)


/*************************** Variable Definitions ***************************/

EthernetFrame TxFrame;		/* Transmit buffer */
EthernetFrame RxFrame;		/* Receive buffer */

/*
 * Buffer descriptors are allocated in uncached memory. The memory is made
 * uncached by setting the attributes appropriately in the MMU table.
 */
#define RXBD_SPACE_BYTES XEmacPs_BdRingMemCalc(XEMACPS_BD_ALIGNMENT, RXBD_CNT)
#define TXBD_SPACE_BYTES XEmacPs_BdRingMemCalc(XEMACPS_BD_ALIGNMENT, TXBD_CNT)


/*
 * Buffer descriptors are allocated in uncached memory. The memory is made
 * uncached by setting the attributes appropriately in the MMU table.
 */
#define RX_BD_LIST_START_ADDRESS	0x0FF00000
#define TX_BD_LIST_START_ADDRESS	0x0FF70000

#define FIRST_FRAGMENT_SIZE 64
//cq
//


//video
#define CTRL_TX_BASE_ADR 0x43c00000
#define CTRL_RX_BASE_ADR 0x43c10000
#define CTRL_I_REG_OFFSET 0x0
#define CTRL_O_REG_OFFSET 0x4
#define ADR_REG_OFFSET 0x8
#define CTRL_TX_I_PTR (*(volatile u32 *) (CTRL_TX_BASE_ADR + CTRL_I_REG_OFFSET))
#define CTRL_TX_O_PTR (*(volatile u32 *) (CTRL_TX_BASE_ADR + CTRL_O_REG_OFFSET))
#define CTRL_TX_ADR_PTR (*(volatile u32 *) (CTRL_TX_BASE_ADR + ADR_REG_OFFSET))
#define CTRL_RX_I_PTR (*(volatile u32 *)  (CTRL_RX_BASE_ADR + CTRL_I_REG_OFFSET))
#define CTRL_RX_O_PTR (*(volatile u32 *)  (CTRL_RX_BASE_ADR + CTRL_O_REG_OFFSET))
#define CTRL_RX_ADR_PTR (*(volatile u32 *)(CTRL_RX_BASE_ADR + ADR_REG_OFFSET))
//
/*
 * Counters to be incremented by callbacks
 */
volatile s32 FramesRx;		/* Frames have been received */
volatile s32 FramesTx;		/* Frames have been sent */
volatile s32 FramesRx_sv;		/* Frames have been received old*/
volatile s32 FramesTx_sv;		/* Frames have been sent old*/
volatile s32 DeviceErrors;	/* Number of errors detected in the device */

u32 TxFrameLength;

#ifndef TESTAPP_GEN
static XScuGic IntcInstance;
#endif

#ifdef __ICCARM__
#pragma data_alignment = 64
XEmacPs_Bd BdTxTerminate;
XEmacPs_Bd BdRxTerminate;
#pragma data_alignment = 4
#else
XEmacPs_Bd BdTxTerminate __attribute__ ((aligned(64)));

XEmacPs_Bd BdRxTerminate __attribute__ ((aligned(64)));
#endif

u32 GemVersion;

/*************************** Function Prototypes ****************************/

/*
 * Example
 */
LONG EmacPsDmaIntrExample(XScuGic *IntcInstancePtr,
			  XEmacPs *EmacPsInstancePtr,
			  u16 EmacPsDeviceId, u16 EmacPsIntrId);

LONG EmacPsDmaSingleFrameIntrExample(XEmacPs * EmacPsInstancePtr);

/*
 * Interrupt setup and Callbacks for examples
 */

static LONG EmacPsSetupIntrSystem(XScuGic * IntcInstancePtr,
				  XEmacPs * EmacPsInstancePtr,
				  u16 EmacPsIntrId);

static void EmacPsDisableIntrSystem(XScuGic * IntcInstancePtr,
				     u16 EmacPsIntrId);

static void XEmacPsSendHandler(void *Callback);
static void XEmacPsRecvHandler(void *Callback);
static void XEmacPsErrorHandler(void *Callback, u8 direction, u32 word);

/*
 * Utility routines
 */
static LONG EmacPsResetDevice(XEmacPs * EmacPsInstancePtr);

void XEmacPs_SetMdioDivisor(XEmacPs *InstancePtr, XEmacPs_MdcDiv Divisor);
/****************************************************************************/
/**
*
* This is the main function for the EmacPs example. This function is not
* included if the example is generated from the TestAppGen test tool.
*
* @param	None.
*
* @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note		None.
*
****************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
	LONG Status;

	xil_printf("Entering into main() \r\n");

	/*
	 * Call the EmacPs DMA interrupt example , specify the parameters
	 * generated in xparameters.h
	 */
	Status = EmacPsDmaIntrExample(&IntcInstance,
				       &EmacPsInstance,
				       EMACPS_DEVICE_ID,
				       EMACPS_IRPT_INTR);

	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Failure in examples");
		return XST_FAILURE;
	}

	xil_printf("Success in examples\r\n");
	return XST_SUCCESS;
}
#endif

/****************************************************************************/
/**
*
* This function demonstrates the usage of the EmacPs driver by sending by
* sending and receiving frames in interrupt driven DMA mode.
*
*
* @param	IntcInstancePtr is a pointer to the instance of the Intc driver.
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*		driver.
* @param	EmacPsDeviceId is Device ID of the EmacPs Device , typically
*		XPAR_<EMACPS_instance>_DEVICE_ID value from xparameters.h.
* @param	EmacPsIntrId is the Interrupt ID and is typically
*		XPAR_<EMACPS_instance>_INTR value from xparameters.h.
*
* @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note		None.
*
*****************************************************************************/
LONG EmacPsDmaIntrExample(XScuGic * IntcInstancePtr,
			  XEmacPs * EmacPsInstancePtr,
			  u16 EmacPsDeviceId,
			  u16 EmacPsIntrId)
{
	LONG Status;
	XEmacPs_Config *Config;
	XEmacPs_Bd BdTemplate;
	u32 SlcrTxClkCntrl;

	/*************************************/
	/* Setup device for first-time usage */
	/*************************************/


	/*
	 *  Initialize instance. Should be configured for DMA
	 *  This example calls _CfgInitialize instead of _Initialize due to
	 *  retiring _Initialize. So in _CfgInitialize we use
	 *  XPAR_(IP)_BASEADDRESS to make sure it is not virtual address.
	 */
	Config = XEmacPs_LookupConfig(EmacPsDeviceId);

	Status = XEmacPs_CfgInitialize(EmacPsInstancePtr, Config,
					Config->BaseAddress);

	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error in initialize");
		return XST_FAILURE;
	}

	GemVersion = ((Xil_In32(Config->BaseAddress + 0xFC)) >> 16) & 0xFFF;

	/* Enable jumbo frames for zynqmp */
	if (GemVersion > 2) {
		XEmacPs_SetOptions(EmacPsInstancePtr, XEMACPS_JUMBO_ENABLE_OPTION);
	}

	if (GemVersion == 2)
	{
		/*************************************/
		/* Setup device for first-time usage */
		/*************************************/

	/* SLCR unlock */
	*(volatile unsigned int *)(SLCR_UNLOCK_ADDR) = SLCR_UNLOCK_KEY_VALUE;
	if (EmacPsIntrId == XPS_GEM0_INT_ID) {
#ifdef XPAR_PS7_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0
		/* GEM0 1G clock configuration*/
		SlcrTxClkCntrl =
		*(volatile unsigned int *)(SLCR_GEM0_CLK_CTRL_ADDR);
		SlcrTxClkCntrl &= EMACPS_SLCR_DIV_MASK;
		SlcrTxClkCntrl |= (XPAR_PS7_ETHERNET_0_ENET_SLCR_1000MBPS_DIV1 << 20);
		SlcrTxClkCntrl |= (XPAR_PS7_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0 << 8);
		*(volatile unsigned int *)(SLCR_GEM0_CLK_CTRL_ADDR) =
								SlcrTxClkCntrl;
#endif
	} else if (EmacPsIntrId == XPS_GEM1_INT_ID) {
#ifdef XPAR_PS7_ETHERNET_1_ENET_SLCR_1000MBPS_DIV1
		/* GEM1 1G clock configuration*/
		SlcrTxClkCntrl =
		*(volatile unsigned int *)(SLCR_GEM1_CLK_CTRL_ADDR);
		SlcrTxClkCntrl &= EMACPS_SLCR_DIV_MASK;
		SlcrTxClkCntrl |= (XPAR_PS7_ETHERNET_1_ENET_SLCR_1000MBPS_DIV1 << 20);
		SlcrTxClkCntrl |= (XPAR_PS7_ETHERNET_1_ENET_SLCR_1000MBPS_DIV0 << 8);
		*(volatile unsigned int *)(SLCR_GEM1_CLK_CTRL_ADDR) =
								SlcrTxClkCntrl;
#endif
	}
	/* SLCR lock */
	*(unsigned int *)(SLCR_LOCK_ADDR) = SLCR_LOCK_KEY_VALUE;
	sleep(1);
	}


	/*
	 * Set the MAC address
	 */
	Status = XEmacPs_SetMacAddress(EmacPsInstancePtr, EmacPsMAC, 1);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error setting MAC address");
		return XST_FAILURE;
	}
	/*
	 * Setup callbacks
	 */
	Status = XEmacPs_SetHandler(EmacPsInstancePtr,
				     XEMACPS_HANDLER_DMASEND,
				     (void *) XEmacPsSendHandler,
				     EmacPsInstancePtr);
	Status |=
		XEmacPs_SetHandler(EmacPsInstancePtr,
				    XEMACPS_HANDLER_DMARECV,
				    (void *) XEmacPsRecvHandler,
				    EmacPsInstancePtr);
	Status |=
		XEmacPs_SetHandler(EmacPsInstancePtr, XEMACPS_HANDLER_ERROR,
				    (void *) XEmacPsErrorHandler,
				    EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error assigning handlers");
		return XST_FAILURE;
	}

	/*
	 * Setup RxBD space.
	 *
	 * We have already defined a properly aligned area of memory to store
	 * RxBDs at the beginning of this source code file so just pass its
	 * address into the function. No MMU is being used so the physical
	 * and virtual addresses are the same.
	 *
	 * Setup a BD template for the Rx channel. This template will be
	 * copied to every RxBD. We will not have to explicitly set these
	 * again.
	 */
	XEmacPs_BdClear(&BdTemplate);

	/*
	 * Create the RxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetRxRing
				       (EmacPsInstancePtr)),
				       (UINTPTR) RX_BD_LIST_START_ADDRESS,
				       (UINTPTR)RX_BD_LIST_START_ADDRESS,
				       XEMACPS_BD_ALIGNMENT,
				       RXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up RxBD space, BdRingCreate");
		return XST_FAILURE;
	}

	Status = XEmacPs_BdRingClone(&(XEmacPs_GetRxRing(EmacPsInstancePtr)),
				      &BdTemplate, XEMACPS_RECV);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up RxBD space, BdRingClone");
		return XST_FAILURE;
	}

	if (GemVersion == 2)
	{
		/*
		 * The BDs need to be allocated in uncached memory. Hence the 1 MB
		 * address range that starts at address 0xFF00000 is made uncached.
		 */
		Xil_SetTlbAttributes(0x0FF00000, 0xc02);

	}

	/*
	 * Setup TxBD space.
	 *
	 * Like RxBD space, we have already defined a properly aligned area
	 * of memory to use.
	 *
	 * Also like the RxBD space, we create a template. Notice we don't
	 * set the "last" attribute. The example will be overriding this
	 * attribute so it does no good to set it up here.
	 */
	XEmacPs_BdClear(&BdTemplate);
	XEmacPs_BdSetStatus(&BdTemplate, XEMACPS_TXBUF_USED_MASK);

	/*
	 * Create the TxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetTxRing
				       (EmacPsInstancePtr)),
				       (UINTPTR) TX_BD_LIST_START_ADDRESS,
				       (UINTPTR) TX_BD_LIST_START_ADDRESS,
				       XEMACPS_BD_ALIGNMENT,
				       TXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up TxBD space, BdRingCreate");
		return XST_FAILURE;
	}
	Status = XEmacPs_BdRingClone(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				      &BdTemplate, XEMACPS_SEND);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up TxBD space, BdRingClone");
		return XST_FAILURE;
	}

	if (GemVersion > 2)
	{
		/*
		 * This version of GEM supports priority queuing and the current
		 * dirver is using tx priority queue 1 and normal rx queue for
		 * packet transmit and receive. The below code ensure that the
		 * other queue pointers are parked to known state for avoiding
		 * the controller to malfunction by fetching the descriptors
		 * from these queues.
		 */
		XEmacPs_BdClear(&BdRxTerminate);
		XEmacPs_BdSetAddressRx(&BdRxTerminate, (XEMACPS_RXBUF_NEW_MASK |
						XEMACPS_RXBUF_WRAP_MASK));
		XEmacPs_Out32((Config->BaseAddress + XEMACPS_RXQ1BASE_OFFSET),
			       (UINTPTR)&BdRxTerminate);
		XEmacPs_BdClear(&BdTxTerminate);
		XEmacPs_BdSetStatus(&BdTxTerminate, (XEMACPS_TXBUF_USED_MASK |
						XEMACPS_TXBUF_WRAP_MASK));
		XEmacPs_Out32((Config->BaseAddress + XEMACPS_TXQBASE_OFFSET),
			       (UINTPTR)&BdTxTerminate);
		Xil_DCacheFlushRange((UINTPTR)(&BdTxTerminate), 64);
	}

	/*
	 * Set emacps to phy loopback
	 */
	if (GemVersion == 2)
	{
		XEmacPs_SetMdioDivisor(EmacPsInstancePtr, MDC_DIV_224);
		sleep(1);
		EmacPsUtilEnterLoopback(EmacPsInstancePtr, EMACPS_LOOPBACK_SPEED_1G);
		XEmacPs_SetOperatingSpeed(EmacPsInstancePtr, EMACPS_LOOPBACK_SPEED_1G);
	}
	else
	{
		XEmacPs_SetMdioDivisor(EmacPsInstancePtr, MDC_DIV_224);
		EmacPsUtilEnterLoopback(EmacPsInstancePtr, EMACPS_LOOPBACK_SPEED);
		XEmacPs_SetOperatingSpeed(EmacPsInstancePtr,EMACPS_LOOPBACK_SPEED);
	}

	/*
	 * Setup the interrupt controller and enable interrupts
	 */
	Status = EmacPsSetupIntrSystem(IntcInstancePtr,
					EmacPsInstancePtr, EmacPsIntrId);

	/*
	 * Run the EmacPs DMA Single Frame Interrupt example
	 */
	while(1){
	Status = EmacPsDmaSingleFrameIntrExample(EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	}
	/*
	 * Disable the interrupts for the EmacPs device
	 */
	EmacPsDisableIntrSystem(IntcInstancePtr, EmacPsIntrId);

	/*
	 * Stop the device
	 */
	XEmacPs_Stop(EmacPsInstancePtr);

	return XST_SUCCESS;
}


/****************************************************************************/
/**
*
* This function demonstrates the usage of the EMACPS by sending and
* receiving a single frame in DMA interrupt mode.
* The source packet will be described by two descriptors. It will be
* received into a buffer described by a single descriptor.
*
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*		driver.
*
* @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note		None.
*
*****************************************************************************/
LONG EmacPsDmaSingleFrameIntrExample(XEmacPs *EmacPsInstancePtr)
{
	LONG Status;
	//u32 PayloadSize = 1000;
	u32 PayloadSize = 520;
	u32 NumRxBuf = 0;
	//u32 RxFrLen;
	XEmacPs_Bd *Bd1Ptr;
	XEmacPs_Bd *BdRxPtr;
	XEmacPs_Bd *BdRxPtr_last;
    int lp;//add
	/*
	 * Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesTx = 0;
	FramesRx_sv = 0; //Aｄｄ
	FramesTx_sv = 0; //cq
	DeviceErrors = 0;

	if (GemVersion > 2) {
		PayloadSize = (7168-14);
	}
	/*
	 * Calculate the frame length (not including FCS)
	 */
	TxFrameLength = XEMACPS_HDR_SIZE + PayloadSize;

	/*
	 * Setup packet to be transmitted
	 */
	EmacPsUtilFrameHdrFormatMAC(&TxFrame, EmacPsMAC);
	EmacPsUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	EmacPsUtilFrameSetPayloadData(&TxFrame, PayloadSize);

	Xil_DCacheFlushRange((UINTPTR)&TxFrame, sizeof(EthernetFrame));

	/*
	 * Clear out receive packet memory area
	 */
	EmacPsUtilFrameMemClear(&RxFrame);

	Xil_DCacheFlushRange((UINTPTR)&RxFrame, sizeof(EthernetFrame));
	Xil_DCacheDisable();
    //mem_if_txの書き込み先頭アドレスに送信バッファのアドレスを設定
    CTRL_TX_ADR_PTR = &TxFrame;
    //mem_if_rxの読み出し先頭アドレスに受信バッファのアドレスを設定
    CTRL_RX_ADR_PTR = &RxFrame;
    //受信ディスクリプタのアドレス設定
    BdRxPtr = RX_BD_LIST_START_ADDRESS;
    //受信キューポインタの設定
    XEmacPs_SetQueuePtr(EmacPsInstancePtr,BdRxPtr, 0, XEMACPS_RECV);
    //受信ディスクリプタへ受信バッファのアドレスを設定
    for(lp=0;lp<32;lp++){
      XEmacPs_BdSetAddressRx(BdRxPtr+lp, (UINTPTR)&RxFrame);
    }
    //最終受信ディスクリプタの算出
    BdRxPtr_last = BdRxPtr + 31;
    //mem_if_txをイネーブル
    CTRL_TX_O_PTR = 0x2;
    //mem_if_ｒxをイネーブル
    CTRL_RX_O_PTR = 0x2;
	//XEmacPs_Start(EmacPsInstancePtr);
    XEmacPs_Start(EmacPsInstancePtr);
    while(1){
    //mem_if_txからの転送リクエストの確認
      if(( CTRL_TX_I_PTR & 0x5)==0x5){//waite req && tx_modde
	    CTRL_TX_O_PTR = 0x3;//ack
	    CTRL_TX_O_PTR = 0x2;
	    while(( CTRL_TX_I_PTR & 0x2)==0x2);//waite tx_end
	    //送信ディスクリプタのアロケーション　Bd1Ptrは初期設定およびインクリメントされる
	    Status = XEmacPs_BdRingAlloc(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				      1, &Bd1Ptr);
	    if (Status != XST_SUCCESS) {
		  EmacPsUtilErrorTrap("Error allocating TxBD");
		  return XST_FAILURE;
	    }
	    //送信ベースアドレス更新
	    EmacPsInstancePtr->TxBdRing.BaseBdAddr = Bd1Ptr;
        // 送信ディスクプリタの設定
	    XEmacPs_BdSetAddressTx(Bd1Ptr, (UINTPTR)&TxFrame);
	    XEmacPs_BdSetLength(Bd1Ptr, TxFrameLength);
	    XEmacPs_BdClearTxUsed(Bd1Ptr);
	    XEmacPs_BdSetLast(Bd1Ptr);
	    //エンキュー 送信ディスクリプタにアドレスセット
	    Status = XEmacPs_BdRingToHw(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				     1, Bd1Ptr);
	    if (Status != XST_SUCCESS) {
		  EmacPsUtilErrorTrap("Error committing TxBD to HW");
		  return XST_FAILURE;
	    }
	    /*
	     * Set the Queue pointers
	     */
	    if (GemVersion > 2) {
	    XEmacPs_SetQueuePtr(EmacPsInstancePtr, EmacPsInstancePtr->TxBdRing.BaseBdAddr, 1, XEMACPS_SEND);
	    }else {
		  XEmacPs_SetQueuePtr(EmacPsInstancePtr,Bd1Ptr, 0, XEMACPS_SEND);
	    }
	    //GEMをスタート
	    XEmacPs_Start(EmacPsInstancePtr);
	    //送信
	    XEmacPs_Transmit(EmacPsInstancePtr);
	    //送信終了待ち
	    while (FramesTx==FramesTx_sv);
	    FramesTx_sv = FramesTx;
    	/*
	     * Now that the frame has been sent, post process our TxBDs.
	     * Since we have only submitted 1 to hardware, then there should
	     * be only 1 ready for post processing.
	     */
	    if (XEmacPs_BdRingFromHwTx(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				    1, &Bd1Ptr) == 0) {
		EmacPsUtilErrorTrap
			("TxBDs were not ready for post processing");
		return XST_FAILURE;
	    }
	   /*
	    * Examine the TxBDs.
	    *
	    * There isn't much to do. The only thing to check would be DMA
	    * exception bits. But this would also be caught in the error
	    * handler. So we just return these BDs to the free list.
	    */
	    Status = XEmacPs_BdRingFree(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				     1, Bd1Ptr);
	    if (Status != XST_SUCCESS) {
		  EmacPsUtilErrorTrap("Error freeing up TxBDs");
		  return XST_FAILURE;
	    }
      }//送信処理終了
      //--------------------------------------------------------------------------------
      //受信処理
      if(XEmacPs_BdRead((BdRxPtr), XEMACPS_BD_ADDR_OFFSET) & XEMACPS_RXBUF_NEW_MASK){
        //受信データ転送
	    while(( CTRL_RX_I_PTR & 0x2)==0x2);//waite rx_end check
        CTRL_RX_O_PTR = 0x3;//rx req
        while(( CTRL_RX_I_PTR & 0x1)==0x0);//waite ack
        CTRL_RX_O_PTR = 0x2;
	    /*
	     * Return the RxBD back to the channel for later allocation. Free
	     * the exact number we just post processed.
	     */
	    Status = XEmacPs_BdRingFree(&(XEmacPs_GetRxRing(EmacPsInstancePtr)),
				     NumRxBuf, BdRxPtr);
	    if (Status != XST_SUCCESS) {
		  EmacPsUtilErrorTrap("Error freeing up RxBDs");
		return XST_FAILURE;
	    }
	    //受信ディスクリプタの使用済みビットを消去
	    XEmacPs_BdWrite((BdRxPtr), XEMACPS_BD_ADDR_OFFSET, XEmacPs_BdRead((BdRxPtr), XEMACPS_BD_ADDR_OFFSET) & ~XEMACPS_RXBUF_NEW_MASK);//cq
	    Xil_DCacheFlushRange((UINTPTR)BdRxPtr, 64);
	    //次の受信ディスクリプタ設定
	    if(BdRxPtr==BdRxPtr_last)
		  BdRxPtr=RX_BD_LIST_START_ADDRESS;
        else
    	  BdRxPtr++;
        XEmacPs_BdSetAddressRx(BdRxPtr, (UINTPTR)&RxFrame);
        //set Rx Queue pointers
        XEmacPs_SetQueuePtr(EmacPsInstancePtr,BdRxPtr, 0, XEMACPS_RECV);
      }//送信処理終了
    }
    /*
	 * Finished this example. If everything worked correctly, all TxBDs
	 * and RxBDs should be free for allocation. Stop the device.
	 */
	XEmacPs_Stop(EmacPsInstancePtr);
	//for(lp_d=0;lp_d<100000;lp_d++);
	return XST_SUCCESS;
}


/****************************************************************************/
/**
* This function resets the device but preserves the options set by the user.
*
* The descriptor list could be reinitialized with the same calls to
* XEmacPs_BdRingClone() as used in main(). Doing this is a matter of
* preference.
* In many cases, an OS may have resources tied up in the descriptors.
* Reinitializing in this case may bad for the OS since its resources may be
* permamently lost.
*
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*		driver.
*
* @return	XST_SUCCESS if successful, else XST_FAILURE.
*
* @note		None.
*
*****************************************************************************/
static LONG EmacPsResetDevice(XEmacPs * EmacPsInstancePtr)
{
	LONG Status = 0;
	u8 MacSave[6];
	u32 Options;
	XEmacPs_Bd BdTemplate;


	/*
	 * Stop device
	 */
	XEmacPs_Stop(EmacPsInstancePtr);

	/*
	 * Save the device state
	 */
	XEmacPs_GetMacAddress(EmacPsInstancePtr, &MacSave, 1);
	Options = XEmacPs_GetOptions(EmacPsInstancePtr);

	/*
	 * Stop and reset the device
	 */
	XEmacPs_Reset(EmacPsInstancePtr);

	/*
	 * Restore the state
	 */
	XEmacPs_SetMacAddress(EmacPsInstancePtr, &MacSave, 1);
	Status |= XEmacPs_SetOptions(EmacPsInstancePtr, Options);
	Status |= XEmacPs_ClearOptions(EmacPsInstancePtr, ~Options);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error restoring state after reset");
		return XST_FAILURE;
	}

	/*
	 * Setup callbacks
	 */
	Status = XEmacPs_SetHandler(EmacPsInstancePtr,
				     XEMACPS_HANDLER_DMASEND,
				     (void *) XEmacPsSendHandler,
				     EmacPsInstancePtr);
	Status |= XEmacPs_SetHandler(EmacPsInstancePtr,
				    XEMACPS_HANDLER_DMARECV,
				    (void *) XEmacPsRecvHandler,
				    EmacPsInstancePtr);
	Status |= XEmacPs_SetHandler(EmacPsInstancePtr, XEMACPS_HANDLER_ERROR,
				    (void *) XEmacPsErrorHandler,
				    EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error assigning handlers");
		return XST_FAILURE;
	}

	/*
	 * Setup RxBD space.
	 *
	 * We have already defined a properly aligned area of memory to store
	 * RxBDs at the beginning of this source code file so just pass its
	 * address into the function. No MMU is being used so the physical and
	 * virtual addresses are the same.
	 *
	 * Setup a BD template for the Rx channel. This template will be copied
	 * to every RxBD. We will not have to explicitly set these again.
	 */
	XEmacPs_BdClear(&BdTemplate);

	/*
	 * Create the RxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetRxRing
				      (EmacPsInstancePtr)),
				      (UINTPTR) RX_BD_LIST_START_ADDRESS,
				      (UINTPTR) RX_BD_LIST_START_ADDRESS,
				      XEMACPS_BD_ALIGNMENT,
				      RXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up RxBD space, BdRingCreate");
		return XST_FAILURE;
	}

	Status = XEmacPs_BdRingClone(&
				      (XEmacPs_GetRxRing(EmacPsInstancePtr)),
				      &BdTemplate, XEMACPS_RECV);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up RxBD space, BdRingClone");
		return XST_FAILURE;
	}

	/*
	 * Setup TxBD space.
	 *
	 * Like RxBD space, we have already defined a properly aligned area of
	 * memory to use.
	 *
	 * Also like the RxBD space, we create a template. Notice we don't set
	 * the "last" attribute. The examples will be overriding this
	 * attribute so it does no good to set it up here.
	 */
	XEmacPs_BdClear(&BdTemplate);
	XEmacPs_BdSetStatus(&BdTemplate, XEMACPS_TXBUF_USED_MASK);

	/*
	 * Create the TxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetTxRing
				      (EmacPsInstancePtr)),
				      (UINTPTR) TX_BD_LIST_START_ADDRESS,
				      (UINTPTR) TX_BD_LIST_START_ADDRESS,
				      XEMACPS_BD_ALIGNMENT,
				      TXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up TxBD space, BdRingCreate");
		return XST_FAILURE;
	}
	Status = XEmacPs_BdRingClone(&
				      (XEmacPs_GetTxRing(EmacPsInstancePtr)),
				      &BdTemplate, XEMACPS_SEND);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Error setting up TxBD space, BdRingClone");
		return XST_FAILURE;
	}

	/*
	 * Restart the device
	 */
	XEmacPs_Start(EmacPsInstancePtr);

	return XST_SUCCESS;
}


/****************************************************************************/
/**
*
* This function setups the interrupt system so interrupts can occur for the
* EMACPS.
* @param	IntcInstancePtr is a pointer to the instance of the Intc driver.
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*		driver.
* @param	EmacPsIntrId is the Interrupt ID and is typically
*		XPAR_<EMACPS_instance>_INTR value from xparameters.h.
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None.
*
*****************************************************************************/
static LONG EmacPsSetupIntrSystem(XScuGic *IntcInstancePtr,
				  XEmacPs *EmacPsInstancePtr,
				  u16 EmacPsIntrId)
{
	LONG Status;

#ifndef TESTAPP_GEN
	XScuGic_Config *GicConfig;
	Xil_ExceptionInit();

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	GicConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, GicConfig,
		    GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
			(Xil_ExceptionHandler)XScuGic_InterruptHandler,
			IntcInstancePtr);
#endif

	/*
	 * Connect a device driver handler that will be called when an
	 * interrupt for the device occurs, the device driver handler performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(IntcInstancePtr, EmacPsIntrId,
			(Xil_InterruptHandler) XEmacPs_IntrHandler,
			(void *) EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
			("Unable to connect ISR to interrupt controller");
		return XST_FAILURE;
	}

	/*
	 * Enable interrupts from the hardware
	 */
	XScuGic_Enable(IntcInstancePtr, EmacPsIntrId);

#ifndef TESTAPP_GEN
	/*
	 * Enable interrupts in the processor
	 */
	Xil_ExceptionEnable();
#endif
	return XST_SUCCESS;
}


/****************************************************************************/
/**
*
* This function disables the interrupts that occur for EmacPs.
*
* @param	IntcInstancePtr is the pointer to the instance of the ScuGic
*		driver.
* @param	EmacPsIntrId is interrupt ID and is typically
*		XPAR_<EMACPS_instance>_INTR value from xparameters.h.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void EmacPsDisableIntrSystem(XScuGic * IntcInstancePtr,
				     u16 EmacPsIntrId)
{
	/*
	 * Disconnect and disable the interrupt for the EmacPs device
	 */
	XScuGic_Disconnect(IntcInstancePtr, EmacPsIntrId);

}

/****************************************************************************/
/**
*
* This the Transmit handler callback function and will increment a shared
* counter that can be shared by the main thread of operation.
*
* @param	Callback is the pointer to the instance of the EmacPs device.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void XEmacPsSendHandler(void *Callback)
{
	XEmacPs *EmacPsInstancePtr = (XEmacPs *) Callback;

	/*
	 * Disable the transmit related interrupts
	 */
	XEmacPs_IntDisable(EmacPsInstancePtr, (XEMACPS_IXR_TXCOMPL_MASK |
		XEMACPS_IXR_TX_ERR_MASK));
	if (GemVersion > 2) {
	XEmacPs_IntQ1Disable(EmacPsInstancePtr, XEMACPS_INTQ1_IXR_ALL_MASK);
	}
	/*
	 * Increment the counter so that main thread knows something
	 * happened.
	 */
	FramesTx++;
}


/****************************************************************************/
/**
*
* This is the Receive handler callback function and will increment a shared
* counter that can be shared by the main thread of operation.
*
* @param	Callback is a pointer to the instance of the EmacPs device.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void XEmacPsRecvHandler(void *Callback)
{
	XEmacPs *EmacPsInstancePtr = (XEmacPs *) Callback;

	/*
	 * Disable the transmit related interrupts
	 */
	XEmacPs_IntDisable(EmacPsInstancePtr, (XEMACPS_IXR_FRAMERX_MASK |
		XEMACPS_IXR_RX_ERR_MASK));
	/*
	 * Increment the counter so that main thread knows something
	 * happened.
	 */
	FramesRx++;
	Xil_DCacheInvalidateRange((UINTPTR)&RxFrame, sizeof(EthernetFrame));
	if (GemVersion > 2) {
		Xil_DCacheInvalidateRange((UINTPTR)RX_BD_LIST_START_ADDRESS, 64);
	}
}


/****************************************************************************/
/**
*
* This is the Error handler callback function and this function increments
* the error counter so that the main thread knows the number of errors.
*
* @param	Callback is the callback function for the driver. This
*		parameter is not used in this example.
* @param	Direction is passed in from the driver specifying which
*		direction error has occurred.
* @param	ErrorWord is the status register value passed in.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void XEmacPsErrorHandler(void *Callback, u8 Direction, u32 ErrorWord)
{
	XEmacPs *EmacPsInstancePtr = (XEmacPs *) Callback;

	/*
	 * Increment the counter so that main thread knows something
	 * happened. Reset the device and reallocate resources ...
	 */
	DeviceErrors++;

	switch (Direction) {
	case XEMACPS_RECV:
		if (ErrorWord & XEMACPS_RXSR_HRESPNOK_MASK) {
			EmacPsUtilErrorTrap("Receive DMA error");
		}
		if (ErrorWord & XEMACPS_RXSR_RXOVR_MASK) {
			EmacPsUtilErrorTrap("Receive over run");
		}
		if (ErrorWord & XEMACPS_RXSR_BUFFNA_MASK) {
			EmacPsUtilErrorTrap("Receive buffer not available");
		}
		break;
	case XEMACPS_SEND:
		if (ErrorWord & XEMACPS_TXSR_HRESPNOK_MASK) {
			EmacPsUtilErrorTrap("Transmit DMA error");
		}
		if (ErrorWord & XEMACPS_TXSR_URUN_MASK) {
			EmacPsUtilErrorTrap("Transmit under run");
		}
		if (ErrorWord & XEMACPS_TXSR_BUFEXH_MASK) {
			EmacPsUtilErrorTrap("Transmit buffer exhausted");
		}
		if (ErrorWord & XEMACPS_TXSR_RXOVR_MASK) {
			EmacPsUtilErrorTrap("Transmit retry excessed limits");
		}
		if (ErrorWord & XEMACPS_TXSR_FRAMERX_MASK) {
			EmacPsUtilErrorTrap("Transmit collision");
		}
		if (ErrorWord & XEMACPS_TXSR_USEDREAD_MASK) {
			EmacPsUtilErrorTrap("Transmit buffer not available");
		}
		break;
	}
	/*
	 * Bypassing the reset functionality as the default tx status for q0 is
	 * USED BIT READ. so, the first interrupt will be tx used bit and it resets
	 * the core always.
	 */
	if (GemVersion == 2) {
	EmacPsResetDevice(EmacPsInstancePtr);
	}
}
