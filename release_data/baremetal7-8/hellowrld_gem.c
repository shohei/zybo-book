#include <stdio.h>
#include "platform.h"
#include "xil_types.h"
//ｍip_line_buf_ctrlのベースアドレスの定義
#define CTRL_TX_BASE_ADR 0x43c00000
#define CTRL_RX_BASE_ADR 0x43c10000
//レジスタのオフセット定義
#define CTRL_I_REG_OFFSET 0x0
#define CTRL_O_REG_OFFSET 0x4
#define ADR_REG_OFFSET 0x8
//レジスタアクセス用ポインタの定義
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
    //mem_if_txの書き込み先頭アドレス指定
    CTRL_TX_ADR_PTR = 0x09000000;
    //mem_if_rxの読み出し先頭アドレス指定
    CTRL_RX_ADR_PTR = 0x09000000;
    //mem_if_txをイネーブル
    CTRL_RX_O_PTR = 0x2;
    //mem_if_rxをイネーブル
    CTRL_TX_O_PTR = 0x2;
    while(1){
      //mem_if_txからの送信リクエスト待ち
      while(( CTRL_TX_I_PTR & 0x1)==0x0);
      //mem_if_txへアクノリッジを発行・書き込み開始
      CTRL_TX_O_PTR = 0x3;
      CTRL_TX_O_PTR = 0x2;
      //mem_if_txの書き込み完了待ち
      while(( CTRL_TX_I_PTR & 0x4)==0x4);
      ///mem_if_rxへ読み出しリクエスト
      CTRL_RX_O_PTR = 0x3;
      ///mem_if_rxからのアクノリッジ待ち
      while(( CTRL_RX_I_PTR & 0x1)==0x0);
      CTRL_RX_O_PTR = 0x2;
      //mem_if_ｒxの読み出し完了待ち
      while(( CTRL_RX_I_PTR & 0x4)==0x4);
    }

    cleanup_platform();
    return 0;
}
