#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include "xgpiops.h"
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

void check_reg_read(){
  xil_printf("Scratch     -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF100));
  xil_printf("Config      -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF104));
  xil_printf("Status(Read Only)      -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF108));
  xil_printf("Counter(Read Only)     -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF10C));
  xil_printf("Brate -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF110));
  xil_printf("Bhold -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF114));

}

void check_reg_write(){
  static unsigned count=0;

  xil_printf("Count is 0x%x  \r\n", count);
  Xil_Out32(ADDR_AXIL_REGS+0xF100,0x0);
  Xil_Out32(ADDR_AXIL_REGS+0xF104,0x00000003);
 
  Xil_Out32(ADDR_AXIL_REGS+0xF110,0x08000000);
  Xil_Out32(ADDR_AXIL_REGS+0xF114,0x04000000);
  //if ((count % 2)){
   // Xil_Out32(ADDR_AXIL_REGS+0xF100, 0x0);
    // xil_printf("Reg0 -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF10C));

    //  Xil_Out32(ADDR_AXIL_REGS+0xF110, 0x0);
  //} else {
   // Xil_Out32(ADDR_AXIL_REGS+0xF100, 0xAAAA1111);
    //xil_printf("Reg0 -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF10C));

    // Xil_Out32(ADDR_AXIL_REGS+0xF110, 0xBBBB2222;
 // }
  //  Xil_Out32(ADDR_AXIL_REGS+0xF104, 0xDDDD0000 + count);
    //  xil_printf("Reg0 -- 0x%x  \r\n", Xil_In32(ADDR_AXIL_REGS+0xF110));

  count = (count + 1)&0xF;
}

int main(){
  xil_printf("SANITY NUMBER:  1\r\n");
  xil_printf("Trenz Eval Board Hardware Testing (Development)\r\n");
  int status = 0;
  status |= init_gpiops();
  if (status != XST_SUCCESS) {
    xil_printf("Hardware initialization has FAILED.\r\n");
    return 0;
  }
  while(1){
    xil_printf("choose an option:\r\n");
    xil_printf("(1) blink LEDS \r\n");
    xil_printf("(2) read registers \r\n");
    xil_printf("(3) write registers \r\n");

    unsigned char c=inbyte();
    xil_printf("pressed:  %c\n\r", c);
    switch(c){
    case '1':
      blink();
      break;
    case '2':
      check_reg_read();
      break;
    case '3':
      check_reg_write();
      break;
    default:
      xil_printf("invalid selection...\n\r");
    }
   }
    return 0;
  } 









