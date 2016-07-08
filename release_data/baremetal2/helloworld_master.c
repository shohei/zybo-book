#include <stdio.h>
#include "platform.h"
#include "xil_cache.h"
//#include "xparameters.h" //vivado2015.1 2015.2
#define XPAR_MYIP_SLAVE_IP_0_S00_AXI_BASEADDR 0x43c00000 //vivado 2015.4
#define XPAR_MYIP_SLAVE_IP_0_S00_AXI_HIGHADDR 0x43c00fff //vivado 2015.4
//myip_slave_ip レジスタ・アクセス用マクロ定義
#define LED (*(volatile unsigned int *) XPAR_MYIP_SLAVE_IP_0_S00_AXI_BASEADDR )
//VRAMのベース・アドレス定義
#define VRAM_BSASE_ADDR 0x08000000
void print(char *str);
int main()
{
  volatile unsigned int *vram_ptr;
  int h,v,i;
  volatile int delay_cnt;
  init_platform();
  Xil_DCacheDisable();//キャッシュの無効化
  print("Hello World\n\r");
  while(1){
    for(i=0;i<16;i++){
      LED=i;
      for(v=0;v<720;v++){//ライン数カウント
        //1ラインあたり4096バイトを割り当て
        vram_ptr = (unsigned int *)(VRAM_BSASE_ADDR + v*4096);
        //水平方向ピクセル数カウント　2ピクセル毎に書き込み
        for(h=0;h<640;h++) {
          if(h<150)
            *vram_ptr = 0xffffffff; //白
          else if(h<300)
            *vram_ptr = 0x001f001f; //赤
          else if(h<450)
            *vram_ptr = 0x07e007e0; //緑
          else if(h<600)
            *vram_ptr = 0xf800f800; //青
          else
            *vram_ptr =  0x0;       //黒
          vram_ptr++;
        }
      }
      for(delay_cnt=0;delay_cnt<2000000;delay_cnt++);
    }
  }
  cleanup_platform();
  return 0;
}
