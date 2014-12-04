//gcc `pkg-config --cflags opencv` `pkg-config --libs opencv` -o medianFilter medianFilter.cpp
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <time.h>
#include <iostream>
#include <stdio.h>


using namespace cv;
using namespace std;



int main (int argc, char** argv)
{
	Mat img,  dst;

	//img = imread("image1_noise.jpg", 0);

	img = imread(argv[1],0);
	if(! img.data )                              // Check for invalid input
	{
		cout <<  "Could not open or find the image" << std::endl ;
		return -1;
	}

	clock_t c0 = clock();
	GaussianBlur(img, dst, Size(3,3), 0.85, 0);
	clock_t c1 = clock();

	double delta=((double)c1-c0)/CLOCKS_PER_SEC;
	printf("TIME:%.3fs\n",delta);

	imwrite(argv[2], dst);
	//imwrite("img_filtered.png",dst);





}

