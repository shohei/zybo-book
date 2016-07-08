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
 
void FifoCtrlWrite(int fd, unsigned char enb);
void allwrite(int fd, unsigned char *buf, int len);
void allread(int fd, unsigned char *buf, int len);
void TxtSave(char *fn, short *iW);
void TxtLoad(char *fn, short *iW);

int main(int argc, char *argv[]) {
 
  int fdw, fdffr, fdffw, i;
  unsigned char buf[WAVEN*4];
  short inWave[WAVEN];
  short outWave[WAVEN];
  long tmplong;
  char input_file[256];

  if (argc < 2) {
      fprintf(stderr, "1st arg must be input file name.\n");
      return -1;
  }

  strcpy(input_file, argv[1]);

  fdw = open("/dev/xillybus_mem_8", O_WRONLY);

  fdffr = open("/dev/xillybus_read_32", O_RDONLY);
  fdffw = open("/dev/xillybus_write_32", O_WRONLY);
 
  if (fdffr < 0) {
    perror("Failed to open Xillybus device file(s)");
    exit(-1);
  }
 
  if (fdffw < 0) {
    perror("Failed to open Xillybus device file(s)");
    exit(-1);
  }
 
  TxtLoad(input_file, inWave);

  for(i = 0; i < WAVEN; i++) {
    buf[i*4+0] = (unsigned char)(0xFF & inWave[i]);
    buf[i*4+1] = (unsigned char)(0xFF & (inWave[i] >> 8));
    buf[i*4+2] = 0;
    buf[i*4+3] = 0;
    printf("buf[%d] = %d\n", i, inWave[i]);
  }

  allwrite(fdffw, buf, WAVEN*4);
  sleep(1);

  FifoCtrlWrite(fdw, 0x09); // Test mode, Test reset
  FifoCtrlWrite(fdw, 0x07); // Test mode, Test read, Test write
  sleep(1);
  FifoCtrlWrite(fdw, 0);

  allread(fdffr, buf, WAVEN*4);

  for(i = 0; i < WAVEN; i++) {
    tmplong = buf[i*4+0];
    tmplong += (buf[i*4+1] << 8);
    if(tmplong < 32768) outWave[i] = (short)(tmplong);
    else outWave[i] = (short)(tmplong - 65536);
    printf("buf[%d] = %d\n", i, outWave[i]);
  }

  close(fdffr);
 
  TxtSave("outwave.txt", outWave);

  return 0;
}

void allread(int fd, unsigned char *buf, int len) {
  int received = 0;
  int rc;

  while (received < len) {
    rc = read(fd, buf + received, len - received);

    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("allread() failed to read");
      exit(1);
    }

    if (rc == 0) {
      fprintf(stderr, "Reached read EOF (?!)\n");
      exit(1);
    }

    received += rc;
  }
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

void FifoCtrlWrite(int fd, unsigned char enb) {
  if (lseek(fd, 0, SEEK_SET) < 0) {
    perror("Failed to seek");
    exit(1);
  }
  allwrite(fd, &enb, 1);
}

void allwrite(int fd, unsigned char *buf, int len) {
  int sent = 0;
  int rc;

  while (sent < len) {
    rc = write(fd, buf + sent, len - sent);

    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("allwrite() failed to write");
      exit(1);
    }

    if (rc == 0) {
      fprintf(stderr, "Reached write EOF (?!)\n");
      exit(1);
    }

    sent += rc;
  }
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


