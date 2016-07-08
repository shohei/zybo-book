#include <cv.h>
#include <highgui.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdint.h>

#define WINDOWX 680
#define WINDOWY 520
#define FLAMEX 640
#define FLAMEY 480
#define OFTX 20
#define OFTY 20
#define ZYBOX 200
#define ZYBOY 150

int SetX(int x);
int SetY(int y);
int GetAccelData();
int _wait(int loop_count);
void allwrite(int fd, unsigned char *buf, int len);
void allread(int fd, unsigned char *buf, int len);
void WritePL(int fd, unsigned char addr, unsigned char data);
unsigned char ReadPL(int fd, unsigned char addr);
void SpiWrite(unsigned char addr, unsigned char data);
unsigned char SpiRead(unsigned char addr);

int fdw, fdr;

int main (int argc, char **argv)
{
  int i;
  IplImage *hist_img;
  int val;
  int x, y;
  float theta;

  fdw = open("/dev/xillybus_mem_8", O_WRONLY);
  fdr = open("/dev/xillybus_mem_8", O_RDONLY);

  // 構造体，画像領域を確保
  hist_img = cvCreateImage (cvSize (WINDOWX, WINDOWY), 8, 1);

  // 画像をクリア
  cvSet (hist_img, cvScalarAll (255), 0);
  cvNamedWindow ("Waveform", CV_WINDOW_AUTOSIZE);

  SpiWrite(0x31, 0x00); // Range is 2g
  SpiWrite(0x2d, 0x08); // Start measurement 

  while(1) {
    cvRectangle (hist_img,
               cvPoint (OFTX, OFTY),
               cvPoint (OFTX+FLAMEX, OFTY+FLAMEY), 
               CV_RGB(255, 255, 255), CV_FILLED, 8, 0);

    val = GetAccelData();
    if(val > 256) val = 256;
    if(val < -256) val = -256;
    theta = acos(val/256.0);
    x = (int)(ZYBOX * cos(theta));
    y = (int)(ZYBOY * sin(theta));

    cvLine (hist_img,
               cvPoint (SetX(x), SetY(y)),
               cvPoint (SetX(-x), SetY(-y)),
               cvScalarAll (0), 5, 8, 0);

    cvShowImage ("Waveform", hist_img);
    if(cvWaitKey(1)>=0) break;
  }

  cvDestroyWindow ("Waveform");
  cvReleaseImage (&hist_img);

  close(fdw);
  close(fdr);

  return 0;
}

int SetX(int x) {
  int res;
  res = OFTX + FLAMEX/2 + x;
  return res;
}

int SetY(int y) {
  int res;
  res = OFTY + FLAMEY/2 - y;
  return res;
}

void SpiWrite(unsigned char addr, unsigned char data) {
  WritePL(fdw, 0x00, addr); // SPI address
  WritePL(fdw, 0x01, data); // SPI write data
  WritePL(fdw, 0x02, 0x01); // SPI start flag set
  _wait(30000);
  WritePL(fdw, 0x02, 0x00); // SPI start flag clear
  _wait(30000);
}

void WritePL(int fd, unsigned char addr, unsigned char data) {
  if (lseek(fd, addr, SEEK_SET) < 0) {
    perror("Failed to seek");
    exit(1);
  }
  allwrite(fd, &data, 1);
}

unsigned char SpiRead(unsigned char addr) {
  unsigned char res;
  unsigned char readaddr;

  readaddr = 0x80 + addr;
  WritePL(fdw, 0x00, readaddr); // SPI address
  WritePL(fdw, 0x01, 0xFF); // SPI dummy write data
  WritePL(fdw, 0x02, 0x01); // SPI start flag set
  _wait(30000);
  WritePL(fdw, 0x02, 0x00); // SPI start flag clear
  res = ReadPL(fdr, 0x03);
  _wait(30000);
  
  return res;
}

unsigned char ReadPL(int fd, unsigned char addr) {
  unsigned char data;
  if (lseek(fd, addr, SEEK_SET) < 0) {
    perror("Failed to seek");
    exit(1);
  }

  allread(fd, &data, 1);
  return data;
}

int GetAccelData() {
  int res;
  unsigned char devid;
  unsigned char zdata_h;
  unsigned char zdata_l;
  unsigned short tmpshort;

  devid = SpiRead(0x00); // Read Device ID
  printf("id = %02X\n", devid);

  zdata_l = SpiRead(0x32); // Read X-axis value (low)
  printf("lval = %02X\n", zdata_l);

  zdata_h = SpiRead(0x33); // Read X-axis value (high)
  printf("hval = %02X\n", zdata_h);

  tmpshort = ((unsigned short)(zdata_h) << 8) + (unsigned short)(zdata_l);
  if(tmpshort < 32768) res = (int)(tmpshort);
  else res = (int)(tmpshort) - 65536;

  return res;
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

int _wait(int loop_count)
{
  volatile int sum, data;
  sum = 0;
  for(data = 0; data < loop_count; data++) {
    sum = (data << 8);
  }
  return sum;
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


