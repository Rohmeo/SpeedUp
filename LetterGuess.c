#import <stdio.h>
#import <stdlib.h>
#include <sys/time.h>

char strTest(char*,char*);

main(){
	
	struct timeval start, cracked, elapsed;
	
	char pass[4] = "zzzz";
	gettimeofday(&start, NULL);
	char c[4] = "0000";
	int i,j,k,l;
		for(c[0]='0';c[0]<'{';c[0]++)
			{	
				for(c[1]='0';c[1]<'{';c[1]++)
				{
					for(c[2]='0';c[2]<'{';c[2]++)
					{
						for(c[3]='0';c[3]<'{';c[3]++)
							{
								if(strTest(&pass[0],&c[0])==1){
									printf("The Password is '%c%c%c%c'\n", c[0],c[1],c[2],c[3]);
									gettimeofday(&cracked,NULL);
								}
							}
					}
				}
			}
	//Timing Computations
	elapsed.tv_sec = (cracked.tv_sec-start.tv_sec);
	if(cracked.tv_usec > start.tv_usec)
	{
		elapsed.tv_usec = (cracked.tv_usec-start.tv_usec);
	}
	else
	{
		elapsed.tv_usec = (((elapsed.tv_sec*1000000)+cracked.tv_usec)-start.tv_usec);
	}
	printf("Elapsed Time: %ld \n",/*((elapsed.tv_sec)*1000000)+*/(elapsed.tv_usec));
}

char strTest(char* pass, char* c){
	if(pass[0]==c[0]){
		if(pass[1]==c[1]){
			if(pass[2]==c[2]){
				if(pass[3]==c[3]){
					return 1;	
				}
				else return 0;
			}
			else return 0;
		}
		else return 0;
	}
	else{
		return 0;
	}
}