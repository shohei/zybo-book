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

  IplImage *imgBef = cvCreateImage(cvSize(w, h), IPL_DEPTH_8U, 1);
  IplImage *imgGray = cvCreateImage(cvSize(w, h), IPL_DEPTH_8U, 1);
  IplImage *imgDiff = cvCreateImage(cvSize(w, h), IPL_DEPTH_8U, 1);

  char winNameCapture[] = "Capture";
  char winNameDiff[] = "Difference";
  char winNameBef[] = "Old Frame";

  cvNamedWindow(winNameCapture, CV_WINDOW_AUTOSIZE);
  cvNamedWindow(winNameBef, CV_WINDOW_AUTOSIZE);
  cvNamedWindow(winNameDiff, CV_WINDOW_AUTOSIZE);

  img = cvQueryFrame(capture);
  cvCvtColor(img, imgBef, CV_BGR2GRAY);  

  while (1) {
    img = cvQueryFrame(capture);
    cvCvtColor(img, imgGray,CV_BGR2GRAY);
    cvAbsDiff(imgGray, imgBef, imgDiff);

    cvShowImage(winNameCapture, img);
    cvShowImage(winNameBef, imgBef);
    cvShowImage(winNameDiff, imgDiff);

    cvCopy(imgGray, imgBef, 0);

    if(cvWaitKey(1) >= 0)
	break;
  }
  
  cvDestroyWindow(winNameCapture);
  cvDestroyWindow(winNameDiff);
  cvDestroyWindow(winNameBef);
  cvReleaseCapture(&capture);

  return 0;
}

