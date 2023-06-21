#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "ColorsInversion.h"
#include "HorizontalFlip.h"
#include "Blur.h"

__global__ void ColorsInversion(unsigned char* Image, int Channels);
__global__ void HorizontalFlip(unsigned char* Image, int Width, int Channels);

__global__ void Blur(unsigned char* Input_Image, unsigned char* Output_Image, int imageWidth, int imageHeight, int channels, int blurRadius);


void inversion(unsigned char* Input_Image, int Height, int Width, int Channels) {
	unsigned char* Dev_Input_Image = NULL;

	//allocate the memory in gpu
	cudaMalloc((void**)&Dev_Input_Image, Height * Width * Channels);

	//copy data from CPU to GPU
	cudaMemcpy(Dev_Input_Image, Input_Image, Height * Width * Channels, cudaMemcpyHostToDevice);

	dim3 Grid_Image(Width, Height);
	ColorsInversion << <Grid_Image, 1 >> > (Dev_Input_Image, Channels);

	//copy processed data back to cpu from gpu
	cudaMemcpy(Input_Image, Dev_Input_Image, Height * Width * Channels, cudaMemcpyDeviceToHost);

	//free gpu mempry
	cudaFree(Dev_Input_Image);
}

__global__ void Blur(unsigned char* Input_Image, unsigned char* Output_Image, int imageWidth, int imageHeight, int channels, int blurRadius)
{
    int x = threadIdx.x + blockIdx.x * blockDim.x;
    int y = threadIdx.y + blockIdx.y * blockDim.y;

    if (x < imageWidth && y < imageHeight)
    {
        float blurValue[4] = { 0.0f };
        int blurSize = 2 * blurRadius + 1;
        int blurArea = blurSize * blurSize;

        for (int c = 0; c < channels; ++c)
        {
            for (int i = -blurRadius; i <= blurRadius; ++i)
            {
                for (int j = -blurRadius; j <= blurRadius; ++j)
                {
                    int neighborX = x + j;
                    int neighborY = y + i;

                    // Handle boundary cases
                    if (neighborX < 0 || neighborX >= imageWidth || neighborY < 0 || neighborY >= imageHeight)
                    {
                        continue;
                    }

                    int offset = (neighborX + neighborY * imageWidth) * channels + c;
                    blurValue[c] += Input_Image[offset];
                }
            }

            blurValue[c] /= blurArea;
        }

        int outputOffset = (x + y * imageWidth) * channels;
        for (int c = 0; c < channels; ++c)
        {
            Output_Image[outputOffset + c] = blurValue[c];
        }
    }
}

void blur(unsigned char* Input_Image, int Height, int Width, int Channels, int blurRadius) {
    unsigned char* Dev_Input_Image = NULL;
    unsigned char* Dev_Output_Image = NULL;

    cudaMalloc((void**)&Dev_Input_Image, Height * Width * Channels);
    cudaMalloc((void**)&Dev_Output_Image, Height * Width * Channels);

    cudaMemcpy(Dev_Input_Image, Input_Image, Height * Width * Channels, cudaMemcpyHostToDevice);

    int blockSizeX = 16;
    int blockSizeY = 16;

    
    int gridDimX = (Width + blockSizeX - 1) / blockSizeX;
    int gridDimY = (Height + blockSizeY - 1) / blockSizeY;

    
    dim3 gridSize(gridDimX, gridDimY);
    dim3 blockSize(blockSizeX, blockSizeY);
    Blur << <gridSize, blockSize >> > (Dev_Input_Image, Dev_Output_Image, Width, Height, Channels, blurRadius);
    cudaMemcpy(Input_Image, Dev_Output_Image, Height * Width * Channels, cudaMemcpyDeviceToHost);

    
    cudaFree(Dev_Input_Image);
    cudaFree(Dev_Output_Image);
}


void horizontalFlip(unsigned char* Input_Image, int Height, int Width, int Channels)
{
	unsigned char* Dev_Input_Image = NULL;

	//allocate the memory in GPU
	cudaMalloc((void**)&Dev_Input_Image, Height * Width * Channels * sizeof(unsigned char));

	//copy data from CPU to GPU
	cudaMemcpy(Dev_Input_Image, Input_Image, Height * Width * Channels * sizeof(unsigned char), cudaMemcpyHostToDevice);

	dim3 blockSize(16, 16);
	dim3 Grid_Image((Width  + blockSize.x - 1)/ blockSize.x, (Height + blockSize.y - 1)/ blockSize.y);
	HorizontalFlip << <Grid_Image, blockSize >> > (Dev_Input_Image, Width, Channels);

	//copy processed data back to CPU from GPU
	cudaMemcpy(Input_Image, Dev_Input_Image, Height * Width * Channels * sizeof(unsigned char), cudaMemcpyDeviceToHost);

	//free GPU memory
	cudaFree(Dev_Input_Image);
}



__global__ void ColorsInversion(unsigned char* Image, int Channels) {
	int x = blockIdx.x;
	int y = blockIdx.y;
	int idx = (x + y * gridDim.x) * Channels;

	for (int i = 0; i < Channels; i++) {
		Image[idx + i] = 255 - Image[idx + i];
	}
}

__global__ void HorizontalFlip(unsigned char* Image, int Width, int Channels)
{

	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < Width / 2)
	{
		int frontIndex = (y * Width + x) * Channels;
		int backIndex = (y * Width + (Width - 1 - x)) * Channels;

		for (int c = 0; c < Channels; ++c)
		{
			unsigned char temp = Image[frontIndex + c];
			Image[frontIndex + c] = Image[backIndex + c];
			Image[backIndex + c] = temp;
		}
	}
}