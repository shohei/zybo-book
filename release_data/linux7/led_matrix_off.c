#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termio.h>
#include <signal.h>

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
	  buf[0]=0x0;
	  buf[1]=0x0;
	  buf[2]=((0x7&y)<<5) + x;
	  buf[3]=0x1&(y>>3);
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
  
}
