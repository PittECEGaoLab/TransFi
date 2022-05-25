#include <stdio.h>
#include <sys/time.h>
#include "mat.h"
int main()
{
	struct timeval time_start = {0};
	struct timeval time_end = {0};
	int i;
	int a = 1;
	int b = 1;
	int c = 0;
	long start =0;
	long end = 0;
	gettimeofday(&time_start,NULL);
	start =  time_start.tv_sec * 1000000 + time_start.tv_usec;
	for(i=0;i<24;i++)
	{
		if(a == b)
		{
			c = c-1;
		
		}
	}
	gettimeofday(&time_end,NULL);
	end =  time_end.tv_sec * 1000000 + time_end.tv_usec;
	printf("\ntime spent:%.7f\n",(double)(end-start)/1000000);
	printf("\ntime spent:%ld\n",end);
	printf("\ntime spent:%ld\n",start);
	printf("\ntime spent:%d\n",c);
}


