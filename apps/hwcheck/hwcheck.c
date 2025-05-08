#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include "xgpiops.h"
#include "xiicps.h"
#include "xaxidma.h"
#include "xstatus.h"
#include "xil_printf.h"
#include "sleep.h"

// MIO pinout:
#define LEDA 7
#define LED0 12
#define LED1 13

//GPIO PS device:
#define GPIOPS_DEVICE_ID XPAR_XGPIOPS_0_DEVICE_ID
#define GPIOPS_CHAN    1
XGpioPs gpiops;

// Device initialization:
// GPIO (MIO and EMIO):

int init_gpiops(){
  xil_printf("initializing PS GPIO interface (MIO and EMIO pins)...");
  XGpioPs_Config *cfg = XGpioPs_LookupConfig(GPIOPS_DEVICE_ID);
  if (NULL == cfg) {
    xil_printf("FAILED.\r\n");
    return XST_FAILURE;
  }
  int status = XGpioPs_CfgInitialize(&gpiops, cfg, cfg->BaseAddr);
  if (status != XST_SUCCESS) {
    xil_printf("FAILED.\r\n");
    return XST_FAILURE;
  }
  XGpioPs_SetDirectionPin(&gpiops, LEDA, 1);
  XGpioPs_SetOutputEnablePin(&gpiops, LEDA, 1);
  XGpioPs_WritePin(&gpiops, LEDA, 0x0);
  XGpioPs_SetDirectionPin(&gpiops, LED0, 1);
  XGpioPs_SetOutputEnablePin(&gpiops, LED0, 1);
  XGpioPs_WritePin(&gpiops, LED0, 0x0);
  XGpioPs_SetDirectionPin(&gpiops, LED1, 1);
  XGpioPs_SetOutputEnablePin(&gpiops, LED1, 1);
  XGpioPs_WritePin(&gpiops, LED1, 0x0);

  xil_printf("success.\r\n");
  return XST_SUCCESS;
}

void blink(){
  static const int nblink = 5;
  static const int wait_usec = 100000;

  xil_printf("BLINK LEDS:  blinking LED 1 (MIO pin)...\r\n");
  for (int iblink=0; iblink<nblink; iblink++){
    XGpioPs_WritePin(&gpiops, LEDA, 1);
    usleep(wait_usec);
    XGpioPs_WritePin(&gpiops, LEDA, 0);
    usleep(wait_usec);
  }
  xil_printf("BLINK LEDS:  blinking LED 1 (MIO pin)...\r\n");
  for (int iblink=0; iblink<nblink; iblink++){
    XGpioPs_WritePin(&gpiops, LED0, 1);
    usleep(wait_usec);
    XGpioPs_WritePin(&gpiops, LED0, 0);
    usleep(wait_usec);
  }
  xil_printf("BLINK LEDS:  blinking LED 2 (MIO pin)...\r\n");
  for (int iblink=0; iblink<nblink; iblink++){
    XGpioPs_WritePin(&gpiops, LED1, 1);
    usleep(wait_usec);
    XGpioPs_WritePin(&gpiops, LED1, 0);
    usleep(wait_usec);
  }
  xil_printf("BLINK LEDS:  done.\r\n");
}

// these are the addresses for the interfaces as read off from the address editor of the block diagram in vivado
#define ADDR_AXIL_REGS  0x40000000

#define SCOPE_GLOBAL 0xF000
#define ROLE_GLOBAL  0x0F00
#define ROLE_TIMING  0x0E00

#define C_ADDR_GLOBAL_SCRA      0x00
#define C_ADDR_GLOBAL_SCRB      0x04
#define C_ADDR_GLOBAL_FW_MAJOR  0x10
#define C_ADDR_GLOBAL_FW_MINOR  0x14
#define C_ADDR_GLOBAL_FW_BUILD  0x18
#define C_ADDR_GLOBAL_HW_CODE   0x1C
#define C_ADDR_GLOBAL_ENABLES   0x20

#define C_ADDR_TIMING_STATUS  0x00
#define C_ADDR_TIMING_STAMP   0x04
#define C_ADDR_TIMING_TRIG    0x20
#define C_ADDR_TIMING_SYNC    0x24

#define C_ADDR_TIMING_LEMO_A_COUNT    0x30
#define C_ADDR_TIMING_LEMO_B_COUNT    0x34

void check_reg_ro(){
  xil_printf("fw major----------- %d   \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_GLOBAL+C_ADDR_GLOBAL_FW_MAJOR));
  xil_printf("fw minor----------- %d   \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_GLOBAL+C_ADDR_GLOBAL_FW_MINOR));
  xil_printf("fw build----------- 0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_GLOBAL+C_ADDR_GLOBAL_FW_BUILD));
  xil_printf("hw code------------ 0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_GLOBAL+C_ADDR_GLOBAL_HW_CODE));
  xil_printf("scratch a---------- 0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_GLOBAL+C_ADDR_GLOBAL_SCRA));
  xil_printf("scratch b---------- 0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_GLOBAL+C_ADDR_GLOBAL_SCRB));
  xil_printf("\r\n");
  xil_printf("enables------------ 0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_GLOBAL+C_ADDR_GLOBAL_ENABLES));
  xil_printf("\r\n");
  xil_printf("timing status-------0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_TIMING+C_ADDR_TIMING_STATUS));
  xil_printf("trig config---------0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_TIMING+C_ADDR_TIMING_TRIG));
  xil_printf("sync config---------0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_TIMING+C_ADDR_TIMING_SYNC));
  xil_printf("\r\n");
  xil_printf("timestamp-----------0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_TIMING+C_ADDR_TIMING_STAMP));

  xil_printf("\r\n");
  xil_printf("LEMO_A_COUNT-----------0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_TIMING+C_ADDR_TIMING_LEMO_A_COUNT));
  xil_printf("\r\n");
  xil_printf("LEMO_B_COUNT-----------0x%x \r\n", Xil_In32(ADDR_AXIL_REGS+SCOPE_GLOBAL+ROLE_TIMING+C_ADDR_TIMING_LEMO_B_COUNT));
}


int main(){
  xil_printf("SANITY NUMBER:  1\r\n");
  xil_printf("Pac-Man Card Low-Level Hardware Testing (Development)\r\n");
  int status = 0;
  status |= init_gpiops();
  if (status != XST_SUCCESS) {
    xil_printf("Hardware initialization has FAILED.\r\n");
    return 0;
  }
  while(1){
    xil_printf("choose an option:\r\n");
    xil_printf("(1) blink LEDs \r\n");
    xil_printf("(2) check RO regs \r\n");

    unsigned char c=inbyte();
    xil_printf("pressed:  %c\n\r", c);
    switch(c){
    case '1':
      blink();
      break;
    case '2':
      check_reg_ro();
      break;
    default:
      xil_printf("invalid selection...\n\r");
    }
  }
  return 0;
}
