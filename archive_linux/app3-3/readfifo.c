#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>

#define WAVEN 2048
 
void EnableFifoWrite(int fd, unsigned char enb);
void allwrite(int fd, unsigned char *buf, int len);
void allread(int fd, unsigned char *buf, int len);
void TxtSave(char *fn, short *iW);

int main(int argc, char *argv[]) {
 
  int fdw, fdr, i;
  unsigned char buf[WAVEN];
  short outWave[WAVEN];

  fdw = open("/dev/xillybus_mem_8", O_WRONLY);

  fdr = open("/dev/xillybus_read_8", O_RDONLY);
 
  if (fdr < 0) {
    perror("Failed to open Xillybus device file(s)");
    exit(-1);
  }
 
  EnableFifoWrite(fdw, 1);
  sleep(1);
  EnableFifoWrite(fdw, 0);

  allread(fdr, buf, WAVEN);

  for(i = 0; i < WAVEN; i++) {
    if(buf[i] < 128) outWave[i] = buf[i];
    else outWave[i] = buf[i] - 256;
    printf("buf[%d] = %d\n", i, outWave[i]);
  }

  close(fdr);
 
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

void EnableFifoWrite(int fd, unsigned char enb) {
  if (lseek(fd, 16, SEEK_SET) < 0) {
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

