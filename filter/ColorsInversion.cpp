#include <iostream>
#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include "ColorsInversion.h"

using namespace std;
using namespace cv;

void Inversion() {
	Mat Input_Image = imread("test.png");
	cout << "Height: " << Input_Image.cols << ", Width: " << Input_Image.rows << ", Channels: " << Input_Image.channels() << endl;
	inversion(Input_Image.data, Input_Image.cols, Input_Image.rows, Input_Image.channels());
	imwrite("colors_inversion_output.png", Input_Image);
}

void Menu() {
	int choice;
	do {
		cout << "Welcome to Filter Cuda App! There are your opions:\n0 - EXIT\n1 - Color Inversion Filter\n";
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