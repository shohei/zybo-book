#include <stdio.h>
#include <highgui.h>

int main(void)
{
    CvCapture *capture = NULL;  
    IplImage*  img;
    char winNameCapture[] = "camcapture";

    capture=cvCaptureFromCAM(0);   
    if(capture==NULL)
    {                          
        fprintf(stderr, "can not find a camera!! \n");
        return -1;
    }

    cvNamedWindow(winNameCapture, CV_WINDOW_AUTOSIZE);

    while(1)
    {
        img=cvQueryFrame(capture);   
        cvShowImage(winNameCapture, img);  

        if(cvWaitKey(1)>=0)        
            break;
    }
    cvDestroyWindow(winNameCapture);    
    cvReleaseCapture(&capture);          

    return 0;
}
