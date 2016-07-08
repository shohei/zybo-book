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
  int x,y;
  unsigned char buf[128];

  if (argc!=2) {
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
  for(y=0;y<16;y++)
    for(x=0;x<32;x++){
          if(x<16)
	    buf[0]=0xf&x;
          else
	    buf[0]=(0xf&x)<<4;
	  buf[1]=y;
	  buf[2]=((0x7&y)<<5) + x;
	  buf[3]=0x1&(y>>3);	  
          fprintf(stdout,"x= %d y= %d : buf3:%x buf2:%x buf1:%x buf0:%x \n",x,y,buf[3],buf[2],buf[1],buf[0]);
          rc=write(fd, buf , 4);
	  if ((rc < 0) && (errno == EINTR))
        continue;
      if (rc < 0) {
        perror("allwrite() failed to write");
      }	
      if (rc == 0) {
        fprintf(stderr, "Reached write EOF (?!)\n");
      }
    }
  while (1) ;
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
