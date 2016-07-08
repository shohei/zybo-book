#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAXN 400

void allwrite(int fd, unsigned char *buf, int len);  
void mywrite(int fd, unsigned char *buf, int len);  
void filter(unsigned char *buf, int len);  

int ringbufl[MAXN];
int ringbufr[MAXN];
int N = 0;

int main(int argc, char *argv[]) {

  int fdr, fdw, rc;
  unsigned char buf[128];
  

  if (argc!=2) {
    fprintf(stderr, "Usage: %s devfile\n", argv[0]);
    exit(1);
  }
  
  fdr = open(argv[1], O_RDONLY);
  fdw = open(argv[1], O_WRONLY);
  
  if (fdr < 0 || fdw < 0) {
    if (errno == ENODEV)
      fprintf(stderr, "(Maybe %s a write-only file?)\n", argv[1]);

    perror("Failed to open devfile");
    exit(1);
  }

  while (1) {
    rc = read(fdr, buf, sizeof(buf));
    
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

    filter(buf, rc);
    allwrite(fdw, buf, rc);
  }
}

void filter(unsigned char *buf, int len) {
  int i;
  int tmpl, tmpr, k;
  float accl, accr;
  float hn = 1.0/((float)(MAXN));

  tmpl = 0; tmpr = 0;

  for(i = 0; i < len; i++) {
    if(i%4 == 0) tmpl = buf[i];
    if(i%4 == 1) tmpl += (buf[i] << 8);
    if(i%4 == 2) tmpr = buf[i];
    if(i%4 == 3) tmpr += (buf[i] << 8);

    accl = 0;
    accr = 0;
    if(i%4 == 3) {
      if((tmpl & 0x8000) == 0x8000) tmpl = (0x10000 - tmpl)*(-1);
      if((tmpr & 0x8000) == 0x8000) tmpr = (0x10000 - tmpr)*(-1);

        ringbufl[N] = tmpl;
        ringbufr[N] = tmpr;

        for(k = N; k >= 0; k--) accl += ((float)(ringbufl[k]) * hn);
        for(k = MAXN-1; k >= N+1; k--) accl += ((float)(ringbufl[k]) * hn);
        tmpl = (int)(accl);

        for(k = N; k >= 0; k--) accr += ((float)(ringbufr[k]) * hn);
        for(k = MAXN-1; k >= N+1; k--) accr += ((float)(ringbufr[k]) * hn);
        tmpr = (int)(accr);

        buf[i-3] = tmpl & 0xFF;
        buf[i-2] = (tmpl >> 8) & 0xFF;
        buf[i-1] = tmpr & 0xFF;
        buf[i-0] = (tmpr >> 8) & 0xFF;
        if(N == MAXN-1) N = 0;
        else N++;
    }
  }
}

void mywrite(int fd, unsigned char *buf, int len) {
  int i;
  int tmpl, tmpr;

  tmpl = 0; tmpr = 0;

  for(i = 0; i < len; i++) {
    if(i%4 == 0) tmpl = buf[i];
    if(i%4 == 1) tmpl += (buf[i] << 8);
    if(i%4 == 2) tmpr = buf[i];
    if(i%4 == 3) tmpr += (buf[i] << 8);
    if(i%4 == 3) {
      if((tmpl & 0x8000) == 0x8000) tmpl = (0x10000 - tmpl)*(-1);
      if((tmpr & 0x8000) == 0x8000) tmpr = (0x10000 - tmpr)*(-1);
      fprintf(stderr, "tmpl[%d] = %d\n", i/4, tmpl);
      fprintf(stderr, "tmpr[%d] = %d\n", i/4, tmpr);
    }
  }
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

