#include <stdio.h>
#include <cv.h>
#include <highgui.h>

int main (int argc, char *argv[]) {
  IplImage *src, *result;
  char winNameOriginal[] = "Original";
  char winNameEdge[] = "Edge";

  if (argc < 2) {
    printf("Usage: ./edgedetect imagefile\n");
    return -1;
  }
  if((src = cvLoadImage(argv[1], CV_LOAD_IMAGE_GRAYSCALE)) == 0) {
    printf("Error: Failed to load %s\n", argv[1]);
    return -1;
  }

  result = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
  cvCanny(src, result, 50.0, 200.0, 3);

  cvNamedWindow(winNameOriginal, CV_WINDOW_AUTOSIZE);
  cvNamedWindow(winNameEdge, CV_WINDOW_AUTOSIZE);
  cvShowImage(winNameOriginal, src);
  cvShowImage(winNameEdge, result);
  cvWaitKey(0);
   
  cvDestroyWindow(winNameOriginal);
  cvDestroyWindow(winNameEdge);
  cvReleaseImage(&src);
  cvReleaseImage(&result);
  
  return 0;
}
