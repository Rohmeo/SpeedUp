#import <stdlib.h>
#import <sys/time.h>
#import <stdio.h>

//This function will recieve the password and an array detailing start points for the brute-force error-checking
__global__ void passCrack(int,char*,char*, char*);

__device__ char strTest(char*, char*);

main(){
	int i;
	
	
	int const length = 2;
	char* pass;
	int const numThreads = 3;
	char const range = 75;
	char *dev_pass, *dev_answer, *dev_divison;
	
	//Create space on host (password, division, answer need allocating)
	size_t strSize = length*sizeof(char);
	pass = (char*) malloc(strSize);
	answer = (char*) malloc(strSize);
	division = (char*) malloc(numThreads*sizeof(char));
	pass = "Hi";
	
	
	//prepare the 'division' variable
	for(i=0;i<numThreads;i++){
		division[i] = range/i;
	}

	//Create space on device, copy to device (password, division need to be copied)
	cudaMalloc((void**)&dev_pass, strSize);
	cudaMemcpy(dev_pass, pass, strSize, cudaMemcpyHostToDevice);
	
	cudaMalloc((void**)&dev_answer, strSize);
	cudaMalloc((void**)&dev_division,(numThreads*sizeof(char)));
	cudaMemcpy(dev_division, division, (numThreads*sizeof(char)),cudaMemcpyHostToDevice);
	
	//Initialize the Kernel
	blockSize = numThreads;
	passCrack<<<blockSize, 1>>>(length, dev_pass, dev_division, dev_answer);
	//Copy result from device to host
	cudaMemcpy(answer, dev_answer, strSize, cudaMemcpyDeviceToHost);
	printf("The password is '%c%c'",answer[0],answer[1]);
	//timing
	
}

__global void passCrack(int length, char* pass, char* division, char* answer){
	int length = 2;
	blockIdx.x = thread;
	char[length*blockDim] start;
	int i,j,k,cpy;
	//prepare the starting values guessing (first two to '0', 2nd pair to '0'+25, etc.)
	for (i=0;i<length;i++){
		start[(thread*length)+i] = '0'+division[thread];
	}
	
	for(i=0;i<(75/blockDim);i++){
		start[(thread*length)+1]='0'+division[thread];  
		for(j=0;j<(75/blockDim.x);j++){
			if(strTest(&pass[0],&start[thread*length]) == 1){
				//This code is written to run on each core, but will only execute once, on the one where the password is matched
				for(cpy=0;cpy<length;cpy++){
					answer[i]=start[(thread*length)+i];
				}
			start[(thread*length)+1]++;
			}
		}
		start[thread*length]++;
	}
}

__device__ char strTest(char* pass, char* guess){
	if(guess[0]==pass[0]){
		if(guess[1]==pass[1]){
			return 1;
		}
		else return 0;
	}
	else return 0;
}
