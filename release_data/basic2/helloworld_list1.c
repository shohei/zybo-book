#include <stdio.h>
#include "platform.h"

//void print(char *str);

int main()
{
	int lp;
    init_platform();
    for(lp=0;lp<1000;lp++){
      //print("Hello World \n\r");
      xil_printf("Hello World %d\n\r",lp);
      sleep(1);
    }
    cleanup_platform();
    return 0;
}
