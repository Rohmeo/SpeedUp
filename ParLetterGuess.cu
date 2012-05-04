#import <stdlib.h>
#import <sys/time.h>
#import <stdio.h>

__global__ void passCrack(int, int*, char*,char*, char*, char*); //variables are length, password, list of divisions within the guessing area, answer, and starting guesses

__device__ char strTest(char*, char*, int*);

main(){
	int i,j;
	int const length = 2;
	char *newpass, *pass, *answer, *division, *start;
	int const numThreads = 3;
	char const range = 75;
	char *dev_pass, *dev_answer, *dev_division, *dev_start;
	
	int *debug, *dev_debug;
	
	//Create space on host (password, division, answer need allocating)
	size_t strSize = length*sizeof(char);
	
	debug = (int*) malloc(numThreads*sizeof(int));
	pass = (char*) malloc(strSize);
	newpass = (char*) malloc(strSize);
	answer = (char*) malloc(strSize);
	division = (char*) malloc(numThreads*sizeof(char));
	start = (char*) malloc(numThreads*length*sizeof(char));
	pass = "Hi";
	
	
	//prepare the 'division' variable
	//for(i=0;i<numThreads;i++){
	//	if(i==0){division[i]=0;}	
	//	else {division[i] = range/i;}
	//	for(j=0;j<length;j++){		//this loop prepares the starting values guessing (first two to '0', 2nd pair to '0'+25, etc.)
	//		start[(i*length)+j] = '0'+division[i];
	//	}
	//}

	//Create space on device, copy to device (password, division, start need to be copied)
	cudaMalloc((void**)&dev_pass, strSize);
	cudaMemcpy(dev_pass, pass, strSize, cudaMemcpyHostToDevice);
	
	cudaMalloc((void**)&dev_start, (numThreads*length*sizeof(char)));
	cudaMemcpy(dev_start, start, (numThreads*length*sizeof(char)), cudaMemcpyHostToDevice);	
	
	cudaMalloc((void**)&dev_debug, (numThreads*sizeof(int)));

	cudaMalloc((void**)&dev_answer, strSize);
	
	cudaMalloc((void**)&dev_division,(numThreads*sizeof(char)));
	cudaMemcpy(dev_division, division, (numThreads*sizeof(char)),cudaMemcpyHostToDevice);
	
	//Initialize the Kernel
	dim3 blockSize = numThreads;
	printf("Start %c%c%c%c%c%c\n",start[0],start[1],start[2],start[3],start[4],start[5]);
	passCrack<<<blockSize, 1>>>(length, dev_debug, dev_pass, dev_division, dev_answer, dev_start);
	
	//Copy result from device to host
	cudaMemcpy(answer, dev_answer, strSize, cudaMemcpyDeviceToHost);
	cudaMemcpy(start,dev_start, (numThreads*length*sizeof(char)), cudaMemcpyDeviceToHost);
	
	cudaMemcpy(debug, dev_debug, (numThreads*sizeof(int)), cudaMemcpyDeviceToHost);
	
	printf("The password is '%c%c'\n",answer[0],answer[1]);
	printf("Start %c%c%c%c%c%c\n",start[0],start[1],start[2],start[3],start[4],start[5]);
	//timing
	printf("Threads: %d\t%d\t%d\n",debug[0],debug[1],debug[2]);
}

__global__ void passCrack(int length, int* debug, char* pass, char* division, char* answer, char* start){
	int thread = blockIdx.x;
	int top = 75/blockDim.x;
	int i,j,k,cpy;
	start[0] = '0';
	start[1] = '0';	
	debug[thread] = thread;
	
	for(start[0]='0';start[0]<'{';start[0]++){
		start[1]='0';  
		for(start[1]='0';start[1]<'{';start[1]++){
			if(strTest(&pass[0],&start[0],&debug[0]) == 1){
				debug[1] = 9;
				//This code is written to run on each core, but will only execute once, on the one where the password is matched
				for(cpy=0;cpy<length;cpy++){
					answer[cpy]=start[cpy];
				}
			}
		}
	}
}

__device__ char strTest(char* pass, char* guess,int* debug){
	if(guess[0]==pass[0]){
		if(guess[1]==pass[1]){
			debug[2] = 10;
			return 1;
		}
		else{
			debug[1]=10;
			return 0;
		}
	}

	else{ 
		debug[0] = 10;
		return 0;
	}
}
