#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/ml/ml.hpp>
#include <iostream>
#include <iomanip>
#include <string>
#include <time.h>

using namespace std;
using namespace cv;

int main()
{
	//Setup the BPNetwork
	CvANN_MLP bp; 
	// Set up BPNetwork's parameters
	CvANN_MLP_TrainParams params;
	params.train_method=CvANN_MLP_TrainParams::BACKPROP;
	params.bp_dw_scale=0.1;
	params.bp_moment_scale=0.1;

	// A C D F H I J L N O P T U X Y Z
	// Set up training data
	float labels[16][16] 
	= { {0,1,1,0, 1,0,0,1, 1,1,1,1, 1,0,0,1}, //A
	{1,1,1,1, 1,0,0,0, 1,0,0,0, 1,1,1,1}, //C
	{1,1,1,0, 1,0,0,1, 1,0,0,1, 1,1,1,0}, //D
	{1,1,1,1, 1,0,0,0, 1,1,1,1, 1,0,0,0}, //F
	{1,0,0,1, 1,1,1,1, 1,1,1,1, 1,0,0,1}, //H
	{1,1,1,1, 0,1,1,0, 0,1,1,0, 1,1,1,1}, //I
	{1,1,1,1, 0,0,0,1, 1,0,0,1, 0,1,1,0}, //J
	{1,0,0,0, 1,0,0,0, 1,0,0,0, 1,1,1,1}, //L
	{1,0,0,1, 1,1,0,1, 1,0,1,1, 1,0,0,1}, //N
	{1,1,1,1, 1,0,0,1, 1,0,0,1, 1,1,1,1}, //O
	{1,1,1,1, 1,0,0,1, 1,1,1,1, 1,0,0,0}, //P
	{1,1,1,1, 0,1,1,0, 0,1,1,0, 0,1,1,0}, //T
	{1,0,0,1, 1,0,0,1, 1,0,0,1, 1,1,1,1}, //U
	{1,0,0,1, 0,1,1,0, 0,1,1,0, 1,0,0,1}, //X
	{1,0,0,1, 1,0,0,1, 0,1,1,0, 0,1,1,0}, //Y
	{1,1,1,1, 0,0,1,0, 0,1,0,0, 1,1,1,1}  //Z
	};
	Mat labelsMat(16, 16, CV_32FC1, labels);

	float trainingData[16][16] 
	= { {0,1,1,0, 1,0,0,1, 1,1,1,1, 1,0,0,1}, //A
	{1,1,1,1, 1,0,0,0, 1,0,0,0, 1,1,1,1}, //C
	{1,1,1,0, 1,0,0,1, 1,0,0,1, 1,1,1,0}, //D
	{1,1,1,1, 1,0,0,0, 1,1,1,1, 1,0,0,0}, //F
	{1,0,0,1, 1,1,1,1, 1,1,1,1, 1,0,0,1}, //H
	{1,1,1,1, 0,1,1,0, 0,1,1,0, 1,1,1,1}, //I
	{1,1,1,1, 0,0,0,1, 1,0,0,1, 0,1,1,0}, //J
	{1,0,0,0, 1,0,0,0, 1,0,0,0, 1,1,1,1}, //L
	{1,0,0,1, 1,1,0,1, 1,0,1,1, 1,0,0,1}, //N
	{1,1,1,1, 1,0,0,1, 1,0,0,1, 1,1,1,1}, //O
	{1,1,1,1, 1,0,0,1, 1,1,1,1, 1,0,0,0}, //P
	{1,1,1,1, 0,1,1,0, 0,1,1,0, 0,1,1,0}, //T
	{1,0,0,1, 1,0,0,1, 1,0,0,1, 1,1,1,1}, //U
	{1,0,0,1, 0,1,1,0, 0,1,1,0, 1,0,0,1}, //X
	{1,0,0,1, 1,0,0,1, 0,1,1,0, 0,1,1,0}, //Y
	{1,1,1,1, 0,0,1,0, 0,1,0,0, 1,1,1,1}  //Z
	};

	Mat trainingDataMat(16, 16, CV_32FC1, trainingData);

	Mat layerSizes=(Mat_<int>(1,3) << 16,32,16);
	bp.create(layerSizes,CvANN_MLP::SIGMOID_SYM,1,1);//CvANN_MLP::SIGMOID_SYM
	//CvANN_MLP::GAUSSIAN
	//CvANN_MLP::IDENTITY
	bp.train(trainingDataMat, labelsMat, Mat(),Mat(), params);



	cv::FileStorage fs("bp.yml", cv::FileStorage::WRITE); // or xml
	bp.write(*fs, "bp"); // don't think too much about the deref, it casts to a FileNode // save weights
	
	Mat sampleMat = (Mat_<float>(1,16) << 1,1,1,1, 0,0,1,0, 0,1,0,0, 1,1,1,1 ); 
	Mat responseMat; 

	clock_t start = clock();
	for(int i = 0; i < 100; i++) {
		bp.predict(sampleMat,responseMat);
	}
	clock_t finish = clock();

	float* p=responseMat.ptr<float>(0);  
	int response=0;  
	for(int i=0;i<16;i++){  
		cout<<p[i]<<" ";  
	} 
	cout << endl;
	double duration = (double)(finish - start) / CLOCKS_PER_SEC;
	cout << "seconds: "<<setprecision(4)<<duration << endl;
	waitKey(0);

}
