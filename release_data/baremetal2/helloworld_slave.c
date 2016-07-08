#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
//myip_slave_ip レジスタ・アクセス用マクロ定義
#define USER_DATA (*(volatile unsigned int *) XPAR_MYIP_SLAVE_IP_0_S00_AXI_BASEADDR )
void print(char *str);
int main()
{
  int i;
  volatile int delay_cnt;
  init_platform();
  print("Hello World\n\r");
  while(1){
    for(i=0;i<16;i++){
      USER_DATA = i; //myip_slave_ipのレジスタへ代入
      for(delay_cnt=0;delay_cnt<10000000;delay_cnt++);
    }
  }
  cleanup_platform();
  return 0;
}
