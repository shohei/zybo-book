//2015.11.07 k.yokomizo
#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_cache.h"
//VRAM�̃x�[�X�A�h���X��`
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
    Xil_DCacheDisable();//�L���b�V���̖�����
    print("Hello World !!\n\r");
    while(1){
    for(i=0;i<16;i++){
      for(v=0;v<480;v++){//���C�����J�E���g
        //1���C��������8192�o�C�g�����蓖��
        vram_ptr = (unsigned int *)(VRAM_P2_BSASE_ADDR + v*8192);
        //���������s�N�Z�����J�E���g�@2�s�N�Z�����ɏ�������
        for(h=0;h<720;h++) {
          if(h<150)
        	*vram_ptr = 0xffffff; //��
          else if(h<300)
          	*vram_ptr = 0xff; //��
          else if(h<450)
          	*vram_ptr = 0xff00; //��
          else if(h<600)
          	*vram_ptr = 0xff0000; //��
          else
        	*vram_ptr =  0x0; //��
         vram_ptr++;
        }
      }
    for(delay_cnt=0;delay_cnt<2000000;delay_cnt++);
    }
    while(1);
  }
}
