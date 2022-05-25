#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>

/*int main()
{
    char MAC_input[2];
    char  line[256];
    size_t len =0;
    ssize_t read;
    int i;
    FILE *fptr=fopen("MAC_Payload.txt","rb");
    fscanf(fptr,"%s[^\n]",MAC_input);
    char c = strtol(MAC_input, 0, 2);
    printf("HEX DATA:%s\n",MAC_input);
    while (fgets(line, sizeof(line), fptr)) {
        /* note that fgets don't strip the terminating \n, checking its
           presence would allow to handle lines longer that sizeof(line)
        printf("%s", line);
    }
    printf("C = %s = %c = %d = 0x%.2X\n", MAC_input, c, c, c);
    fclose(fptr);
    printf("Hello world!\n");

    return 0;
}*/

int main(int argc, char* argv[])
{

    char const* const fileName = argv[1]; /* should check that argc > 1 */

    int file_num;
    char line[2];
    int a[100];
    unsigned char src;
    int c1;
    int m=0;
    int count =0;
    int yushu;
    uint8_t data_inject[200];
    char data_hex[200];
    char hex[16]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
    uint8_t *ic = "\x43\x28\x5F";
    //printf("ic = %s\n",ic);
    for (file_num = 1; file_num<10;file_num++)
    {
        
        int i2;
        int b_I;
        int i0=0;
        int i =0;
        int j =0;
        int var[10]={1,2,3,4,5,6,7,8,9,10};
        int temp = rand()%10;
        clock_t tic = clock();
        for (i = 0; i < 500000; i++) {
            i2 = 1001100011^ 0110011000;
            b_I = i2;
        
        for (j = 0; j< 10; j++) {
             if (temp==var[j])
                {
                    break;
                }
        }
        /*  Left-shift */
        m = 1;

        /*  Update x1 */
        }
        clock_t toc = clock();
        printf("Elapsed: %f seconds\n", (double)(toc - tic) / CLOCKS_PER_SEC);

       
   }
    /* may check feof here to make a difference between eof and io failure -- network
       timeout for instance */


    return 0;
}
