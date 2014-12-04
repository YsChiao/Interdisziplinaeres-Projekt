// source.cpp
//
// Example program for bcm2835 library
// Shows how to interface with SPI to transfer a number of bytes to and from an SPI device
//
// After installing bcm2835, you can build this 
// with something like:
// gcc `pkg-config --cflags opencv` `pkg-config --libs opencv` -o source source.cpp -lbcm2835
// sudo ./source
//
// Author: Mike McCauley
// Copyright (C) 2012 Mike McCauley
// $Id: RF22.h,v 1.21 2012/05/30 01:51:25 mikem Exp $

#include <bcm2835.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <stdio.h>
#include <time.h>
#include <string>
#include <vector>
#include <iostream>

#define RST  RPI_V2_GPIO_P1_03 //sda signal, reset

using namespace cv;
using namespace std;



string type2str(int type) 
{
	string r;
	uchar depth = type & CV_MAT_DEPTH_MASK;
	uchar chans = 1 + (type >> CV_CN_SHIFT);

	switch ( depth ) {
	case CV_8U:  r = "8U"; break;
	case CV_8S:  r = "8S"; break;
	case CV_16U: r = "16U"; break;
	case CV_16S: r = "16S"; break;
	case CV_32S: r = "32S"; break;
	case CV_32F: r = "32F"; break;
	case CV_64F: r = "64F"; break;
	default:     r = "User"; break;
	}

	r += "C";
	r += (chans+'0');

	return r;
};

string Mat2str(Mat bwimg, int N)
{
	vector<uchar> data(bwimg.ptr(),bwimg.ptr()+N);
	string s(data.begin(), data.end());
	printf("String size = %d\n", s.length());
	return s;

}

void reset()
{       
	bcm2835_gpio_write(RST,HIGH);
	bcm2835_gpio_write(RST,LOW);
}


int main(int argc, char **argv)
{



	if (!bcm2835_init()){return 1;}
	bcm2835_gpio_fsel(RST,  BCM2835_GPIO_FSEL_OUTP);

	bcm2835_spi_begin();
	bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // The default
	bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);                   // The default
	bcm2835_spi_setClockDivider(22);                              // 88ns 11.363636Mhz
	bcm2835_spi_chipSelect(BCM2835_SPI_CS1);                      // User slave select
	bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS1, LOW);      // the default


	reset(); 

	Mat img = imread(argv[1]);
	//Mat img = imread("image1.jpg", CV_LOAD_IMAGE_COLOR);
	if(! img.data )                              // Check for invalid input
	{
		cout <<  "Could not open or find the image" << std::endl ;
		return -1;
	}



	Mat bwimg;
	cvtColor(img,bwimg,CV_BGR2GRAY);
	
	int rows = bwimg.rows;
	int cols = bwimg.cols;

	string ty = type2str(bwimg.type());
	printf("Matrix: %s %dx%d \n", ty.c_str(), cols, rows);
	const int N = cols*rows;

	string imageData = Mat2str(bwimg, N);

	string tail= "ab";
	string imageDataFix = imageData+tail;


	const int m = 230400;
	const int n = 230402;
	const int l = 231060;

	char buf[m];
	char buf1[n];
	char buf2[l];

	for(int i = 0; i < l; i++)
	{ 
		if (i < n) 
		{
			buf1[i] = imageDataFix[i]; 
			buf2[i] = imageDataFix[i];
		}
		else
		{
			buf2[i] = 0;
		}


	}


	cout <<"size of buf1 " <<sizeof(buf1)<<endl;
	cout <<"size of buf2 " <<sizeof(buf2)<<endl;
	printf("send to spi buf1: %d  %d  %d  %d  %d  %d  %d  %d  %d \n", 
		buf1[0], buf1[1], buf1[2], buf1[3], buf1[4], buf1[5], buf1[16381], buf1[16382], buf1[230401]);
	printf("send to spi buf2: %d  %d  %d  %d  %d  %d  %d  %d  %d \n", 
		buf2[0], buf2[1], buf2[2], buf2[3], buf2[4], buf2[5], buf2[231057], buf2[231058], buf2[231059]);


	clock_t c0=clock();
	bcm2835_spi_transfern(buf2,l);
	clock_t c1=clock();

	double delta=((double)c1-c0)/CLOCKS_PER_SEC;
	printf("SIZE:%.2fMB\n",N/1024./1024.);
	printf("TIME:%.3fs\n",delta);
	printf("SPEED:%.3fMB/s\n",(N/1024./1024.)/delta);

	// buf1 will now be filled with the data that was read from the slave
	printf("read from spi: %d  %d  %d  %d  %d  %d  %d  %d  %d \n",  
		buf2[660], buf2[661], buf2[662], buf2[663], buf2[664], buf2[665], buf2[231057], buf2[231058], buf2[231059]);



	char result [m];
	for(int i = 0; i < m; i++)
	{ 
		result[i] = buf2[i+659]; 
	}
	cout <<"size of result " <<sizeof(result)<<endl;
	printf("Read from SPI: %d  %d  %d  %d  %d  %d  %d  %d  %d\n", 
		result[0], result[1], result[2], result[3],result[4],result[5], result[230397], result[230398], result[230399]);

	Mat resultImage (rows,cols,CV_8UC1,(unsigned char*)result);
	imwrite(argv[2], resultImage);


	bcm2835_spi_end();
	bcm2835_close();
	
	printf("------------------ Done --------------------\n"); 



	return 0;
}
