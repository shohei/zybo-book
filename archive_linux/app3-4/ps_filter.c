#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>
#include <string.h>

#define WAVEN 512
 
void EnableFifoWrite(int fd, unsigned char enb);
void allwrite(int fd, unsigned char *buf, int len);
void allread(int fd, unsigned char *buf, int len);
void TxtSave(char *fn, short *iW);
void TxtLoad(char *fn, short *iW);

int main(int argc, char *argv[]) {
 
  short inWave[WAVEN];
  short outWave[WAVEN];
  long tmplong;
  short x0, x1, x2, y0, y1, y2;
  short a0, a1, a2, b1, b2;
  int i;
  long HnXn_20b;
  char input_file[256];

  if (argc < 2) {
      fprintf(stderr, "1st arg must be input file name.\n");
      return -1;
  }

  strcpy(input_file, argv[1]);

  x0 = 0; x1 = 0; x2 = 0;
  y0 = 0; y1 = 0; y2 = 0;

// 3k
  a0 = 0x01EB;
  a1 = 0x03D7;
  a2 = 0x01EB;
  b1 = 0x5D08;
  b2 = 0xDB49;

  TxtLoad(input_file, inWave);

  for(i = 0; i < WAVEN; i++) {
    tmplong = 0;
    HnXn_20b = ((long)a0*(long)x0) >> 11;
    tmplong += HnXn_20b;
    HnXn_20b = ((long)a1*(long)x1) >> 11;
    tmplong += HnXn_20b;
    HnXn_20b = ((long)a2*(long)x2) >> 11;
    tmplong += HnXn_20b;
    HnXn_20b = ((long)b1*(long)y1) >> 11;
    tmplong += HnXn_20b;
    HnXn_20b = ((long)b2*(long)y2) >> 11;
    tmplong += HnXn_20b;

    tmplong = tmplong >> 3;
    if(tmplong > 32767) y0 = 32767;
    else if(tmplong < -32768) y0 = -32768;
    else y0 = tmplong;

    outWave[i] = y0;

    x2 = x1;
    x1 = x0;
    x0 = inWave[i];

    y2 = y1;
    y1 = y0;
  }

  TxtSave("ps_outwave.txt", outWave);

  return 0;
}

void TxtSave(char *fn, short *iW)
{
  int i;
  char charline[40];
  FILE *fp;

  fp = fopen( fn, "w" );
  if( fp == NULL ){
    printf( "%s cannot be opened.\n", fn );
    exit(1);
  }

  fseek( fp, 0L, SEEK_SET );
  for( i = 0; i < WAVEN; i++) {
    sprintf(charline, "%d\n", iW[i]);
    fputs(charline, fp);
//    printf( "%d\n", iW[i] );
  }
  fclose( fp );
}

void TxtLoad(char *fn, short *iW)
{
  int count = 0;
  char charline[40];
  FILE *fp;

  fp = fopen( fn, "r" );
  if( fp == NULL ){
    printf( "%s cannot be opened.\n", fn );
    exit(1);
  }

  fseek( fp, 0L, SEEK_SET );
  while( fgets(charline, 40, fp) != NULL ) {
    iW[count] = atoi(charline);
//    printf( "%d  %d\n", count, iW[count] );
    count++;

    if(count == WAVEN) {
      break;
    }
  }
  fclose( fp );
}


