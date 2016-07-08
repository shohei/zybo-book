#include <stdio.h>
#include <highgui.h>
#include <cv.h>

int main(int argc, char** argv) {
  CvCapture *capture = NULL;

  capture = cvCreateCameraCapture(0);
  if(capture == NULL){
    printf("can not find a camera!!");
    return -1;
  }

  IplImage *img = NULL;
  img = cvQueryFrame(capture);
  const int w = img->width;
  const int h = img->height;

  IplImage *imgGray = cvCreateImage(cvGetSize(img), img->depth, img->nChannels);
  IplImage *imgGau = cvCreateImage(cvGetSize(img), img->depth, img->nChannels);

  char winNameCapture[] = "Capture";
  char winNameGau[] = "Gaussian";

  cvNamedWindow(winNameCapture, CV_WINDOW_AUTOSIZE);
  cvNamedWindow(winNameGau, CV_WINDOW_AUTOSIZE);

  img = cvQueryFrame(capture);

  while (1) {
      img = cvQueryFrame(capture);
      cvSmooth (img, imgGau, CV_GAUSSIAN, 11, 0, 0, 0);
      cvShowImage(winNameCapture, img);
      cvShowImage(winNameGau, imgGau);

    if(cvWaitKey(1) >= 0)
      break;
  }
  
  cvDestroyWindow(winNameCapture);
  cvDestroyWindow(winNameGau);
  cvReleaseCapture(&capture);

  return 0;
}

