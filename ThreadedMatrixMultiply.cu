#include <stdio.h>
#include <time.h>
#include <sys/time.h>

typedef struct{
	int width;
	int height;
	int* elements;
} Matrix;

__global__ void matrixProduct(Matrix, Matrix, Matrix);

main()
{
	//Declare vars, constants
	int const MatSize=9;
	Matrix Matrix1, Matrix2, Matrix3, Result;
	Matrix dev_Matrix1, dev_Matrix2, dev_Result;
	
	Matrix1.width = MatSize; Matrix1.height = MatSize;
	Matrix2.width = MatSize; Matrix2.height = MatSize;
	Result.width = MatSize; Result.height = MatSize;
	Matrix3.width = MatSize; Matrix3.height = MatSize;
	 
	dim3 blockSize(MatSize+1,MatSize+1);
	dim3 gridSize(1,1);

	int i,j;
	struct timeval start, elapsed, end;

	size_t MemSize = (MatSize+1) * (MatSize+1) * sizeof(int);
	Matrix1.elements = (int*) malloc(MemSize);
	Matrix2.elements = (int*) malloc(MemSize);
	Matrix3.elements = (int*) malloc(MemSize);
	Result.elements = (int*) malloc(MemSize);
	
	//Initialize matrices with random values
	for(i=0;i<=MatSize;i++)
	{
		for(j=0;j<=MatSize;j++)
		{
			Matrix1.elements[i*Matrix1.width+j]=i*Matrix1.width+j;
			Matrix2.elements[i*Matrix1.width+j]=i*Matrix1.width+j;
		}
	}
	gettimeofday(&start,NULL);
	printf("Start Values %ld, %ld\n",start.tv_sec,start.tv_usec);
	
	//Transfer matrices to device memory
	
	dev_Matrix1.height = Matrix1.height; dev_Matrix1.width = Matrix1.width;
	cudaMalloc((void**)&dev_Matrix1.elements,MemSize);
	cudaMemcpy(dev_Matrix1.elements, Matrix1.elements, MemSize, cudaMemcpyHostToDevice);

	dev_Matrix2.height = Matrix2.height; dev_Matrix2.width = Matrix2.width;
	cudaMalloc((void**)&dev_Matrix2.elements,MemSize);
	cudaMemcpy(dev_Matrix2.elements, Matrix2.elements, MemSize, cudaMemcpyHostToDevice);

	cudaMemcpy(Matrix3.elements, dev_Matrix2.elements, MemSize, cudaMemcpyDeviceToHost);
	
	dev_Result.height = Result.height; dev_Result.width = Result.width;
	cudaMalloc((void**)&dev_Result.elements,MemSize);
	
		
	//Kernel Declaration
	matrixProduct<<<blockSize,gridSize>>>(dev_Matrix1, dev_Matrix2, dev_Result);
	cudaMemcpy(Result.elements, dev_Result.elements, MemSize, cudaMemcpyDeviceToHost);
	
	gettimeofday(&end,NULL);
	printf("End Values %ld, %ld\n",end.tv_sec,end.tv_usec);
	printf("Matrix 1:\n");
	for(i=0;i<=MatSize;i++)
	{
		for(j=0;j<=MatSize;j++)
			printf("%d\t",Matrix3.elements[(i*Matrix3.width)+j]);
		printf("\n");
	}
	printf("Matrix 2:\n");
	for(i=0;i<=MatSize;i++)
		{
			for(j=0;j<=MatSize;j++)
				printf("%d\t",Matrix2.elements[(i*Matrix2.width)+j]);
			printf("\n");
		}
	printf("Result:\n");
	for(i=0;i<=MatSize;i++)
		{
			for(j=0;j<=MatSize;j++)
				printf("%d\t",Result.elements[i*Result.width+j]);
			printf("\n");
		}
	//Compute time elapsed
	
	elapsed.tv_sec = (end.tv_sec-start.tv_sec);
	if(end.tv_usec > start.tv_usec){
		elapsed.tv_usec = (end.tv_usec-start.tv_usec);
	}
	else{
		elapsed.tv_usec = (((elapsed.tv_sec*1000000)+end.tv_usec)-start.tv_usec);
	}
	printf("Elapsed Time: %ld \n",/*((elapsed.tv_sec)*1000000)+*/(elapsed.tv_usec));
}

__global__ void matrixProduct(Matrix Mat1, Matrix Mat2, Matrix Res)
{
	int row = blockIdx.x;
	int col = blockIdx.y;
	int k,sum;
	sum=0;
	for(k=0;k<=Mat1.width;k++)
	{
		sum=sum+(Mat1.elements[(row*Mat1.width)+k])*(Mat2.elements[(k*Mat2.width)+col]);
	}
	Res.elements[(row*Res.width)+col]=sum;
}
