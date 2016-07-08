#include <stdio.h>
#include "platform.h"
#include "xil_cache.h"
//#include "xparameters.h" //vivado2015.1 2015.2
#define XPAR_MYIP_SLAVE_IP_0_S00_AXI_BASEADDR 0x43c00000 //vivado 2015.4
#define XPAR_MYIP_SLAVE_IP_0_S00_AXI_HIGHADDR 0x43c00fff //vivado 2015.4
//myip_slave_ip ���W�X�^�E�A�N�Z�X�p�}�N����`
#define LED (*(volatile unsigned int *) XPAR_MYIP_SLAVE_IP_0_S00_AXI_BASEADDR )
//VRAM�̃x�[�X�E�A�h���X��`
#define VRAM_BSASE_ADDR 0x08000000
void print(char *str);
int main()
{
  volatile unsigned int *vram_ptr;
  int h,v,i;
  volatile int delay_cnt;
  init_platform();
  Xil_DCacheDisable();//�L���b�V���̖�����
  print("Hello World\n\r");
  while(1){
    for(i=0;i<16;i++){
      LED=i;
      for(v=0;v<720;v++){//���C�����J�E���g
        //1���C��������4096�o�C�g�����蓖��
        vram_ptr = (unsigned int *)(VRAM_BSASE_ADDR + v*4096);
        //���������s�N�Z�����J�E���g�@2�s�N�Z�����ɏ�������
        for(h=0;h<640;h++) {
          if(h<150)
            *vram_ptr = 0xffffffff; //��
          else if(h<300)
            *vram_ptr = 0x001f001f; //��
          else if(h<450)
            *vram_ptr = 0x07e007e0; //��
          else if(h<600)
            *vram_ptr = 0xf800f800; //��
          else
            *vram_ptr =  0x0;       //��
          vram_ptr++;
        }
      }
      for(delay_cnt=0;delay_cnt<2000000;delay_cnt++);
    }
  }
  cleanup_platform();
  return 0;
}
