//2015.11.07 k.yokomizo
#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_cache.h"
//VRAMのベースアドレス定義
#define VRAM_BSASE_ADDR 0x8000000
#define VRAM_P1_BSASE_ADDR VRAM_BSASE_ADDR
#define VRAM_P2_BSASE_ADDR VRAM_BSASE_ADDR + 0x1000000
void print(char *str);
int main()
{
	volatile unsigned int *vram_ptr;
	int h,v,i;
	volatile int delay_cnt;
    init_platform();
    Xil_DCacheDisable();//キャッシュの無効化
    print("Hello World !!\n\r");
    while(1){
    for(i=0;i<16;i++){
      for(v=0;v<480;v++){//ライン数カウント
        //1ラインあたり8192バイトを割り当て
        vram_ptr = (unsigned int *)(VRAM_P2_BSASE_ADDR + v*8192);
        //水平方向ピクセル数カウント　2ピクセル毎に書き込み
        for(h=0;h<720;h++) {
          if(h<150)
        	*vram_ptr = 0xffffff; //白
          else if(h<300)
          	*vram_ptr = 0xff; //赤
          else if(h<450)
          	*vram_ptr = 0xff00; //緑
          else if(h<600)
          	*vram_ptr = 0xff0000; //青
          else
        	*vram_ptr =  0x0; //黒
         vram_ptr++;
        }
      }
    for(delay_cnt=0;delay_cnt<2000000;delay_cnt++);
    }
    while(1);
  }
}
