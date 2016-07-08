#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <math.h>

short a0, a1, a2, b1, b2;

void allwrite(int fd, unsigned char *buf, int len);

int main(int argc, char *argv[]) {

  int fd;
  int address;
  unsigned char data[10];
  FILE *fp;
  char *fname = "coeff.txt";
    char str_a0[20];
    char str_a1[20];
    char str_a2[20];
    char str_b1[20];
    char str_b2[20];

  fp = fopen( fname, "r" );
  if( fp == NULL ){
    printf( "%s cannot be opened.\n", fname );
    return -1;
  }

  if( fgets( str_a0, 20, fp ) != NULL ){
    printf( "%s", str_a0 );
  }
  if( fgets( str_a1, 20, fp ) != NULL ){
    printf( "%s", str_a1 );
  }
  if( fgets( str_a2, 20, fp ) != NULL ){
    printf( "%s", str_a2 );
  }
  if( fgets( str_b1, 20, fp ) != NULL ){
    printf( "%s", str_b1 );
  }
  if( fgets( str_b2, 20, fp ) != NULL ){
    printf( "%s", str_b2 );
  }

  fclose( fp );

  a0 = (short)(atof(str_a0) * pow(2, 14));
  a1 = (short)(atof(str_a1) * pow(2, 14));
  a2 = (short)(atof(str_a2) * pow(2, 14));
  b1 = (short)((-1) * atof(str_b1) * pow(2, 14));
  b2 = (short)((-1) * atof(str_b2) * pow(2, 14));

  fprintf(stdout, "a0 = %04X\n", a0);
  fprintf(stdout, "a1 = %04X\n", a1);
  fprintf(stdout, "a2 = %04X\n", a2);
  fprintf(stdout, "b1 = %04X\n", b1);
  fprintf(stdout, "b2 = %04X\n", b2);

  fd = open("/dev/xillybus_mem_8", O_WRONLY);

  address = 0;

  data[0] = (unsigned char)(a0 & 0xFF);
  data[1] = (unsigned char)((a0 >> 8) & 0xFF);
  data[2] = (unsigned char)(a1 & 0xFF);
  data[3] = (unsigned char)((a1 >> 8) & 0xFF);
  data[4] = (unsigned char)(a2 & 0xFF);
  data[5] = (unsigned char)((a2 >> 8) & 0xFF);
  data[6] = (unsigned char)(b1 & 0xFF);
  data[7] = (unsigned char)((b1 >> 8) & 0xFF);
  data[8] = (unsigned char)(b2 & 0xFF);
  data[9] = (unsigned char)((b2 >> 8) & 0xFF);

  if (lseek(fd, address, SEEK_SET) < 0) {
    perror("Failed to seek");
    exit(1);
  }
  allwrite(fd, data, 10);


  return 0;
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

