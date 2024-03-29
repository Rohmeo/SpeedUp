#include <stdio.h>
#include <time.h>
#include <sys/time.h>

typedef struct{
	int width;
	int height;
	int* elements;
} Matrix;

__global__ void matrixProduct(Matrix, Matrix, Matrix, int*, int);

int hostMatrixProduct(Matrix, Matrix, int, int);
void printMatrix(Matrix, char[]);

main()
{
	//Declare vars, constants
	int const MatSize=3;
	Matrix Matrix1, Matrix2, Result, Res_Check;
	Matrix dev_Matrix1, dev_Matrix2, dev_Result;
	int sections, numThreads;
	int *startPoint, *dev_startPoint;
	
	//For generalization purposes
	numThreads = 3;
	sections=(MatSize*MatSize)/numThreads;
	
	Matrix1.width = MatSize; Matrix1.height = MatSize;
	Matrix2.width = MatSize; Matrix2.height = MatSize;
	Result.width = MatSize; Result.height = MatSize;
	Res_Check.width = MatSize; Res_Check.height = MatSize;
	 
	dim3 blockSize=numThreads;
	dim3 gridSize(1,1);

	int i,j;
	struct timeval start, elapsed, end;

	size_t MemSize = (MatSize+1) * (MatSize+1) * sizeof(int);
	Matrix1.elements = (int*) malloc(MemSize);
	Matrix2.elements = (int*) malloc(MemSize);
	Result.elements = (int*) malloc(MemSize);
	Res_Check.elements = (int*) malloc(MemSize);
	startPoint = (int*) malloc(sections*sizeof(int));
	
	//Initialize matrices with random values
	for(i=1;i<=MatSize;i++)
	{
		for(j=1;j<=MatSize;j++)
		{
			Matrix1.elements[(i*Matrix1.width)+j]=(i*Matrix1.width)+j;
			Matrix2.elements[(i*Matrix1.width)+j]=(i*Matrix1.width)+j;
		}
	}
	
	//Fill out the array of starting points in the matrix
	for(i=0;i<=sections;i++)
	{
		startPoint[i]=(sections*i)+1;
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
	
	cudaMalloc((void**)&dev_startPoint,sections*sizeof(int));
	cudaMemcpy(dev_startPoint,startPoint,(sections*sizeof(int)),cudaMemcpyHostToDevice);
	
	dev_Result.height = Result.height; dev_Result.width = Result.width;
	cudaMalloc((void**)&dev_Result.elements,MemSize);
	
		
	//Kernel Declaration
	matrixProduct<<<blockSize,gridSize>>>(dev_Matrix1, dev_Matrix2, dev_Result,dev_startPoint,sections);
	cudaMemcpy(Result.elements, dev_Result.elements, MemSize, cudaMemcpyDeviceToHost);
	
	gettimeofday(&end,NULL);
	printf("End Values %ld, %ld\n",end.tv_sec,end.tv_usec);
	
	printMatrix(Matrix1,"Matrix 1\n");
	printMatrix(Matrix2, "Matrix 2\n");
	printMatrix(Result, "Result Matrix\n");
	//Compute time elapsed
	
	elapsed.tv_sec = (end.tv_sec-start.tv_sec);
	if(end.tv_usec > start.tv_usec)
	{
		elapsed.tv_usec = (end.tv_usec-start.tv_usec);
	}
	else
	{
		elapsed.tv_usec = (((elapsed.tv_sec*1000000)+end.tv_usec)-start.tv_usec);
	}
	printf("Elapsed Time: %ld \n",/*((elapsed.tv_sec)*1000000)+*/(elapsed.tv_usec));
	
	//Check the output for errors
	for(i=1;i<=MatSize;i++)
	{
		for(j=1;j<=MatSize;j++)
		{
			Res_Check.elements[(i*Res_Check.width)+j] = hostMatrixProduct(Matrix1, Matrix2, i, j);
			if(Res_Check.elements[(i*Res_Check.width)+j] != Result.elements[(i*Result.width)+j])
			{
				printf("Error found in row %d, column %d\n",i,j);
				printf("Value in parallel: %d, Value in host comp: %d\n",Result.elements[(i*Result.width)+j],Res_Check.elements[(i*Res_Check.width)+j]);
			}
		}
	}
	printMatrix(Res_Check,"Error-Check Matrix\n");
	printf("Error Check finished\n");
}

int hostMatrixProduct(Matrix Mat1, Matrix Mat2,int row, int col)
{
	int k,sum;
	sum=0;
	for(k=1;k<=Mat1.width;k++)
	{	
		sum=sum+(Mat1.elements[(row*Mat1.width)+k])*(Mat2.elements[(k*Mat2.width)+col]);	
	}
	return sum;
}

void printMatrix(Matrix Mat, char name[])
{
	int i,j;
	printf(name);
	for(i=1;i<=Mat.width;i++)
		{
			for(j=1;j<=Mat.width;j++)
			{
				printf("%d\t",Mat.elements[(i*Mat.width)+j]);
			}
			printf("\n");
		}
	return;
}

__global__ void matrixProduct(Matrix Mat1, Matrix Mat2, Matrix Res, int* start, int threadSize)
{
	int thread = blockIdx.x;
	int k,sum,index,row,col;
	
	sum=0;
	for(index=start[thread];index<=(start[thread]+threadSize);index++)
	{
		row = index / Mat1.width;
		col = index % Mat1.width;
		for(k=1;k<=Mat1.width;k++)
		{
			sum=sum+(Mat1.elements[(row*(Mat1.width+1))+k])*(Mat2.elements[(k*(Mat2.width+1))+col]);
		}
		Res.elements[index]=sum;
	}
}
