// spin.c
//
// Example program for bcm2835 library
// Shows how to interface with SPI to transfer a number of bytes to and from an SPI device
//
// After installing bcm2835, you can build this 
// with something like:
// gcc -o spin spin.c -l bcm2835
// sudo ./spin
//
// Or you can test it before installing with:
// gcc -o spin -I ../../src ../../src/bcm2835.c spin.c
// sudo ./spin
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
    // If you call this, it will not actually access the GPIO
// Use for testing
//        bcm2835_set_debug(1);
    
    if (!bcm2835_init()){return 1;}
    bcm2835_gpio_fsel(RST,  BCM2835_GPIO_FSEL_OUTP);
    
    bcm2835_spi_begin();
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // The default
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);                   // The default
    bcm2835_spi_setClockDivider(10); // 40ns  25Mhz 
    //bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_16);
    bcm2835_spi_chipSelect(BCM2835_SPI_CS1);                      // User slave select
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS1, LOW);      // the default
    
	
    reset(); 
    Mat img = imread(argv[1]);
	Mat bwimg;
    cvtColor(img,bwimg,CV_BGR2GRAY);
	
    int rows = bwimg.rows;
	int cols = bwimg.cols;
	
	string ty = type2str(bwimg.type());
	printf("Matrix: %s %dx%d \n", ty.c_str(), cols, rows);
	int N = cols*rows;
	
	string imageData = Mat2str(bwimg, N);
	printf("%d %d %d\n",imageData[0],imageData[1],imageData[2]);

	string tail= "ab";
	string imageDataFix = imageData+tail;

	// char *buf  = new char[imageData.length()+1];
	// char *buf1 = new char[imageDataFix.length()+1];
	
	char buf[N+1];
	char buf1[N+3];
	
	for(int i = 0; i < N; i++)
	{ 
		buf[i] = imageData[i]; 
		buf1[i] = imageDataFix[i];
	}
	
	
	
	// strcpy(buf,imageData.c_str());
	// strcpy(buf1,imageDataFix.c_str());
	
    cout <<"size of buf " <<sizeof(buf)<<endl;
	cout <<"size of buf1 " <<sizeof(buf1)<<endl;
	printf("send to spi: %d  %d  %d  %d  %d  %d  %d  %d  %d \n", 
             buf[0], buf[1], buf[2], buf[3], buf[4], buf[5], buf[16381], buf[16382], buf[16383]);
    printf("send to spi: %d  %d  %d  %d  %d  %d  %d  %d  %d \n", 
            buf1[0], buf1[1], buf1[2], buf1[3], buf1[4], buf1[5], buf1[16381], buf1[16382], buf1[16383]);			
	
			
 	clock_t c0=clock();
    bcm2835_spi_transfern(buf1,N+2);
    clock_t c1=clock();
	
	
	cout <<"size of buf1 " <<sizeof(buf1)<<endl;
    double delta=((double)c1-c0)/CLOCKS_PER_SEC;
	printf("SIZE:%.2fMB\n",N/1024./1024.);
    printf("TIME:%.3fs\n",delta);
    printf("SPEED:%.3fMB/s\n",(N/1024./1024.)/delta);

    // buf1 will now be filled with the data that was read from the slave
     printf("read from spi: %d  %d  %d  %d  %d  %d  %d  %d  %d  %d  %d  %d  %d\n", 
            buf1[0], buf1[1], buf1[2], buf1[3],buf1[4],buf1[5], buf1[6], buf1[7], buf1[16381], buf1[16382], buf1[16383],buf1[16384],buf1[16385] ); 
		   
	
	
	
	char result [N];
	for(int i = 0; i < N; i++)
	{ 
		result[i] = buf1[i+2]; 
	}
    printf("Read from SPI: %d  %d  %d  %d  %d  %d  %d  %d  %d\n", 
           result[0], result[1], result[2], result[3],result[4],result[5], result[16380], result[16381], result[16382]);
		   
    Mat resultImage (rows,cols,CV_8UC1,(unsigned char*)result);
	imwrite(argv[2], resultImage);
		   

	// delete []buf;
	// delete []buf1;
	// delete []buf1;
    bcm2835_spi_end();
    bcm2835_close();
    return 0;
}
