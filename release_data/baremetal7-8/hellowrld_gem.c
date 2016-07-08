#include <stdio.h>
#include "platform.h"
#include "xil_types.h"
//��ip_line_buf_ctrl�̃x�[�X�A�h���X�̒�`
#define CTRL_TX_BASE_ADR 0x43c00000
#define CTRL_RX_BASE_ADR 0x43c10000
//���W�X�^�̃I�t�Z�b�g��`
#define CTRL_I_REG_OFFSET 0x0
#define CTRL_O_REG_OFFSET 0x4
#define ADR_REG_OFFSET 0x8
//���W�X�^�A�N�Z�X�p�|�C���^�̒�`
#define CTRL_TX_I_PTR (*(volatile u32 *) (CTRL_TX_BASE_ADR + CTRL_I_REG_OFFSET))
#define CTRL_TX_O_PTR (*(volatile u32 *) (CTRL_TX_BASE_ADR + CTRL_O_REG_OFFSET))
#define CTRL_TX_ADR_PTR (*(volatile u32 *) (CTRL_TX_BASE_ADR + ADR_REG_OFFSET))
#define CTRL_RX_I_PTR (*(volatile u32 *)  (CTRL_RX_BASE_ADR + CTRL_I_REG_OFFSET))
#define CTRL_RX_O_PTR (*(volatile u32 *)  (CTRL_RX_BASE_ADR + CTRL_O_REG_OFFSET))
#define CTRL_RX_ADR_PTR (*(volatile u32 *)(CTRL_RX_BASE_ADR + ADR_REG_OFFSET))
void print(char *str);

int main()
{
    init_platform();
    print("ZYBO test_1 \n\r");
    //mem_if_tx�̏������ݐ擪�A�h���X�w��
    CTRL_TX_ADR_PTR = 0x09000000;
    //mem_if_rx�̓ǂݏo���擪�A�h���X�w��
    CTRL_RX_ADR_PTR = 0x09000000;
    //mem_if_tx���C�l�[�u��
    CTRL_RX_O_PTR = 0x2;
    //mem_if_rx���C�l�[�u��
    CTRL_TX_O_PTR = 0x2;
    while(1){
      //mem_if_tx����̑��M���N�G�X�g�҂�
      while(( CTRL_TX_I_PTR & 0x1)==0x0);
      //mem_if_tx�փA�N�m���b�W�𔭍s�E�������݊J�n
      CTRL_TX_O_PTR = 0x3;
      CTRL_TX_O_PTR = 0x2;
      //mem_if_tx�̏������݊����҂�
      while(( CTRL_TX_I_PTR & 0x4)==0x4);
      ///mem_if_rx�֓ǂݏo�����N�G�X�g
      CTRL_RX_O_PTR = 0x3;
      ///mem_if_rx����̃A�N�m���b�W�҂�
      while(( CTRL_RX_I_PTR & 0x1)==0x0);
      CTRL_RX_O_PTR = 0x2;
      //mem_if_��x�̓ǂݏo�������҂�
      while(( CTRL_RX_I_PTR & 0x4)==0x4);
    }

    cleanup_platform();
    return 0;
}
