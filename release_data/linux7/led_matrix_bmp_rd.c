#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termio.h>
#include <signal.h>

/* streamwrite.c -- Demonstrate write to a Xillybus FIFO
   
This simple command-line application is given one argument: The device
file to write to. The data is read from standard input.

This program can't be substituted by UNIX' 'cat', because the latter works
at line-by-line basis.

See http://www.xillybus.com/doc/ for usage examples an information.

*/


int main(int argc, char *argv[]) {

  int fd, rc;
  FILE *fp_bmp;
  int x,y,y_r;
  unsigned char buf[10];
  unsigned char buf_bmp[1536];
  char *bmp_filename="test_1.bmp";

  if (argc!=3) {
    fprintf(stderr, "Usage: %s devfile\n", argv[0]);
    exit(1);
  }
  
  fd = open(argv[1], O_WRONLY);
  
  if (fd < 0) {
    if (errno == ENODEV)
      fprintf(stderr, "(Maybe %s a read-only file?)\n", argv[1]);

   perror("Failed to open devfile");
    exit(1);
  }
 
 //fp_bmp = fopen(bmp_filename,"rb");
 fp_bmp = fopen(argv[2],"rb");
  
  fread(buf_bmp,sizeof(unsigned char),0x36,fp_bmp);
  fread(buf_bmp,sizeof(unsigned char),0x600,fp_bmp);
  fclose(fp_bmp);
  //for(y=15;y>=0;y=y-1)
  for(y=0;y<16;y++)
    for(x=0;x<32;x=x+1){
      y_r = 15 -y;
      buf[0]= (0xf0 & buf_bmp[y*96 + x*3+1]) + (0xf & (buf_bmp[y*96 + x*3+2]>>4));
      buf[1]= buf_bmp[y*96+ x*3]>>4;
      buf[2]=((0x7&y_r)<<5) + x;
      buf[3]=0x1&(y_r>>3);
      //fprintf(stdout,"pos=%d %x %x %x %x %x \n",x,buf_bmp[x*3+2],buf_bmp[x*3+1],buf_bmp[x*3],buf[1],buf[0]);
      rc=write(fd, buf ,4 );
      if ((rc < 0) && (errno == EINTR))
        continue;
      if (rc < 0) {
        perror("allwrite() failed to write");
      }	
      if (rc == 0) {
        fprintf(stderr, "Reached write EOF (?!)\n");
      }
    }
  //while (1) ;
/*
  config_console(); // Configure standard input not to wait for CR

  while (1) {
    // Read from standard input = file descriptor 0
    rc = read(0, buf, sizeof(buf));
    
    if ((rc < 0) && (errno == EINTR))
      continue;
    
    if (rc < 0) {
      perror("allread() failed to read");
      exit(1);
    }
    
    if (rc == 0) {
      fprintf(stderr, "Reached read EOF.\n");
      exit(0);
    }
    
    allwrite(fd, buf, rc);
  }
  */
  
  
}

/* 
   Plain write() may not write all bytes requested in the buffer, so
   allwrite() loops until all data was indeed written, or exits in
   case of failure, except for EINTR. The way the EINTR condition is
   handled is the standard way of making sure the process can be suspended
   with CTRL-Z and then continue running properly.

   The function has no return value, because it always succeeds (or exits
   instead of returning).

   The function doesn't expect to reach EOF either.
*/
