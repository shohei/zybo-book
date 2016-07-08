#include <stdio.h>
//2015.11.07 k.yokomizo
int main(){
unsigned char da_r_i,da_g_i,da_b_i;
unsigned char da_r_d1,da_g_d1,da_b_d1;
int lp;
unsigned int ans;
char mode_sw;
for(mode_sw=0;mode_sw<4;mode_sw++){
  printf("mode_sr:%2x \n",mode_sw);
  for(lp=0;lp<256;lp++){
    da_r_i = lp;
    da_g_i = lp;
    da_b_i = lp;
    if(lp==0x7f)
      printf("--\n");
    ans = hls_block(da_r_i,da_g_i,da_b_i,da_r_d1,da_g_d1,da_b_d1,mode_sw);
    da_r_d1 = lp;
    da_g_d1 = lp;
    da_b_d1 = lp;
    printf("r:%2x g:%2x b:%2x ans:%8x \n",da_r_i,da_g_i,da_b_i,ans);
  }
}
}
