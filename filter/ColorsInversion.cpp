#include <iostream>
#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "ColorsInversion.h"
#include "HorizontalFlip.h"
#include "Blur.h"

using namespace std;
using namespace cv;

void Inversion() {
	Mat Input_Image = imread("test.png");
	cout << "Height: " << Input_Image.cols << ", Width: " << Input_Image.rows << ", Channels: " << Input_Image.channels() << endl;
	inversion(Input_Image.data, Input_Image.cols, Input_Image.rows, Input_Image.channels());
	imwrite("colors_inversion_output.png", Input_Image);
}

void HorizontalFlip()
{
	Mat Input_Image = imread("test.png");
	//Mat Output;
	//flip(Input_Image, Output, 1);
	cout << "Height: " << Input_Image.cols << ", Width: " << Input_Image.rows << ", Channels: " << Input_Image.channels() << endl;
	horizontalFlip(Input_Image.data, Input_Image.rows, Input_Image.cols, Input_Image.channels());
	imwrite("horizontal_flip_output.png", Input_Image);
}

void Blur()
{
	Mat Input_Image = imread("test.png");
	cout << "Height: " << Input_Image.cols << ", Width: " << Input_Image.rows << ", Channels: " << Input_Image.channels() << endl;
	blur(Input_Image.data, Input_Image.rows, Input_Image.cols, Input_Image.channels(), 5);
	imwrite("blur_output.png", Input_Image);
}



void Menu() {
	int choice;
	do {
		cout << "Welcome to Filter Cuda App! There are your options:\n0 - EXIT\n1 - Color Inversion Filter\n2 - Horizontal Flip Filter\n3 - Blur Filter\n";
		cin >> choice;

		switch (choice)
		{
		case 0:
			cout << "EXIT";
			break;
		case 1:
			cout << "Output saved as \"colors_inversion_output.png\"\n\n";
			Inversion();
			break;
		case 2:
			cout << "Output saved as \"horizontal_flip_output.png\"\n\n";
			HorizontalFlip();
			break;
		case 3:
			cout << "Output saved as \"blur_output.png\"\n\n";
			Blur();
			break;
		default:
			cout << "This isn't an option.\n\n";
			break;
		}

	} while (choice != 0);
}

int main() {

	Menu();
	//system("pause");

	return 0;
}