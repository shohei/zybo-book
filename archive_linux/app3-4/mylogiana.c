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

#define SCALEX 720
#define SCALEY 320
#define OFTX 40
#define OFTY 20
#define STEPX 5
#define WAVEN 512

void DrawScale(CvArr* img);
void p_Bin(int Din, char *Outchar); 
void DrawOneDiv(CvArr* img, int x1, int y1, int pattern1, int pattern2, int xstep);
void DrawOneDivAna(CvArr* img, int x1, int y1, int pattern1, int pattern2, int xstep);
void TxtLoad(char *fn, unsigned long *iW);

int main (int argc, char **argv)
{
  int i;
  unsigned long outWave[WAVEN];
  IplImage *hist_img;
  int val, valp1;

  // 構造体，画像領域を確保
  hist_img = cvCreateImage (cvSize (800, 360), 8, 1);

  // 画像をクリア
  cvSet (hist_img, cvScalarAll (255), 0);
  cvRectangle (hist_img,
               cvPoint (OFTX, OFTY),
               cvPoint (OFTX+SCALEX, OFTY+SCALEY), 
               cvScalarAll (0), 1, 8, 0);

  DrawScale(hist_img);

  TxtLoad("outwave.txt", outWave);

  for(i = 0; i < 500; i++) {
    if(STEPX*i < SCALEX) {
      val = (int)(0xFF & (outWave[i] >> 8));
      valp1 = (int)(0xFF & (outWave[i+1] >> 8));
      DrawOneDiv(hist_img, OFTX+STEPX*i, OFTY+0, val, valp1, STEPX);
    }
  }

  // 画像を表示，キーが押されたときに終了
  cvNamedWindow ("Waveform", CV_WINDOW_AUTOSIZE);
  cvShowImage ("Waveform", hist_img);
  cvWaitKey (0);

  cvDestroyWindow ("Waveform");
  cvReleaseImage (&hist_img);

  return 0;
}

void DrawOneDiv(CvArr* img, int x1, int y1, int pattern1, int pattern2, int xstep) {
  int i;
  int ystep = 40;
  int r = 255;
  int g = 0;
  int b = 0;

  CvScalar color = CV_RGB( rand()&255, rand()&255, rand()&255 );

  char tmpchar1[100];
  char tmpchar2[100];
  p_Bin(pattern1, tmpchar1);
  p_Bin(pattern2, tmpchar2);

  color = CV_RGB(0, 255, 0);

  for(i = 0; i < 8; i++) {

    if(tmpchar1[i] == '0') {
      cvLine( img, cvPoint(x1, y1 + i*ystep + 30),
                   cvPoint(x1 + xstep, y1 + i*ystep + 30),
                   color, 1, 8, 0);
      if(tmpchar2[i] == '1') cvLine( img, cvPoint(x1 + xstep, y1 + i*ystep + 10),
                                          cvPoint(x1 + xstep, y1 + i*ystep + 30),
                                          color, 1, 8, 0);
    } else {
      cvLine( img, cvPoint(x1, y1 + i*ystep + 10),
                   cvPoint(x1 + xstep, y1 + i*ystep + 10),
                   color, 1, 8, 0);
      if(tmpchar2[i] == '0') cvLine( img, cvPoint(x1 + xstep, y1 + i*ystep + 30),
                                          cvPoint(x1 + xstep, y1 + i*ystep + 10),
                                          color, 1, 8, 0);
    }
  }

}

void DrawOneDivAna(CvArr* img, int x1, int y1, int pattern1, int pattern2, int xstep) {
  int i;

  CvScalar color = CV_RGB( rand()&255, rand()&255, rand()&255 );

  char tmpchar1[100];
  char tmpchar2[100];
  p_Bin(pattern1, tmpchar1);
  p_Bin(pattern2, tmpchar2);

  color = CV_RGB(0, 255, 0);

  int p1, p2;

  p1 = pattern1 &= 0x00FF;
  p2 = pattern2 &= 0x00FF;
  p1 ^= 0x80;
  p2 ^= 0x80;
  cvLine( img, cvPoint(x1, y1 + SCALEY - p1*SCALEY/0x100),
               cvPoint(x1 + xstep, y1 + SCALEY - p2*SCALEY/0x100),
               color, 1, 8, 0);
}

void DrawScale(CvArr* img) {
  float oneperiod = 1.0/48000.0;
  float fullperiod = oneperiod * SCALEX / STEPX;
  CvFont font;
  int font_face[] = {
    CV_FONT_HERSHEY_SIMPLEX,
    CV_FONT_HERSHEY_PLAIN,
    CV_FONT_HERSHEY_DUPLEX,
    CV_FONT_HERSHEY_COMPLEX,
    CV_FONT_HERSHEY_TRIPLEX,
    CV_FONT_HERSHEY_COMPLEX_SMALL,
    CV_FONT_HERSHEY_SCRIPT_SIMPLEX,
    CV_FONT_HERSHEY_SCRIPT_COMPLEX
  };
  char tmpchar[16];

  cvInitFont(&font, font_face[0], 0.5, 0.5, 0, 1, 8);

  sprintf( tmpchar, "%6.2f ms", 0.0 );
  cvPutText(img, tmpchar, cvPoint(OFTX - 5, OFTY + SCALEY - 10) , &font, CV_RGB(0, 0, 0));
  sprintf( tmpchar, "%6.2f ms", fullperiod*1000/3 );
  cvPutText(img, tmpchar, cvPoint(OFTX + SCALEX/3 - 55, OFTY + SCALEY - 10) , &font, CV_RGB(0, 0, 0));
  sprintf( tmpchar, "%6.2f ms", fullperiod*1000*2/3 );
  cvPutText(img, tmpchar, cvPoint(OFTX + SCALEX*2/3 - 55, OFTY + SCALEY - 10) , &font, CV_RGB(0, 0, 0));
  sprintf( tmpchar, "%6.2f ms", fullperiod*1000 );
  cvPutText(img, tmpchar, cvPoint(OFTX + SCALEX - 55, OFTY + SCALEY - 10) , &font, CV_RGB(0, 0, 0));

  cvLine( img, cvPoint(OFTX + SCALEX/3, OFTY + SCALEY),
                   cvPoint(OFTX + SCALEX/3, OFTY),
                   CV_RGB(200, 200, 200), 1, 8, 0);
  cvLine( img, cvPoint(OFTX + SCALEX*2/3, OFTY + SCALEY),
                   cvPoint(OFTX + SCALEX*2/3, OFTY),
                   CV_RGB(200, 200, 200), 1, 8, 0);
  cvLine( img, cvPoint(OFTX, OFTY + SCALEY/2),
                   cvPoint(OFTX + SCALEX, OFTY + SCALEY/2),
                   CV_RGB(200, 200, 200), 1, 8, 0);
}

void p_Bin(int Din, char *Outchar) 
{
  int p_BITS = 8;
  int k2 = 2;
  int mods = 0;
  int i, k;
  int divs;

  divs = Din;

  if( divs >= 0 ) {
    for ( k = 0; k < 34; k++ ) Outchar[k] = 0;
    for ( k = 0; k < p_BITS; k++ ) Outchar[k] = '0';
    i = p_BITS - 1;
    while (divs != 0) {
      mods = divs % k2;
      divs = (divs - mods) / k2;
      switch( mods ) {
        case 0: Outchar[i] = '0'; break;
        case 1:  Outchar[i] = '1'; break;
      }
      i--;
    }
  } else {
    divs = divs * (-1) - 1;
    for ( k = 0; k < 34; k++ ) Outchar[k] = 0;
    for ( k = 0; k < p_BITS; k++ ) Outchar[k] = '1';
    i = p_BITS - 1;
    while (divs != 0) {
      mods = divs % k2;
      divs = (divs - mods) / k2;
      switch( mods ) {
        case 0: Outchar[i] = '1'; break;
        case 1:  Outchar[i] = '0'; break;
      }
      i--;
    }
  }
}

void TxtLoad(char *fn, unsigned long *iW)
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

  
