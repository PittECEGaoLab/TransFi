#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>


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
    FILE* file = fopen("MAC_Payload.txt", "rb"); /* should check the result */
    char line[20000];
    int a[100];
    unsigned char src;
    int c1;
    int m=0;
    int count =0;
    int yushu;
    uint8_t data_inject[2000];
    //char data_hex[200];
    char hex[16]={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
    uint8_t *ic = "\x43\x28\x5F";
    printf("ic = %s\n",ic);

    while (fgets(line, sizeof(line), file)) {
        /* note that fgets don't strip the terminating \n, checking its
           presence would allow to handle lines longer that sizeof(line) */
        c1 = 0;
        int i=0;
        printf("%s\n", line);
        c1 = strtol(line, 0, 2);

        printf("c = %d\n",c1);
        uint8_t y = c1;
        data_inject[count] = y;
        printf("y = %c\n",y);
        printf("data_inject = %s\n",data_inject);
        /*while(c1>0)
        {
            yushu = c1%16;
            a[i++] = yushu;
            c1 = c1/16;

        }
        //printf("i = %d\n",i);
        //int temp =0;
        for(i=i-1;i>=0;i--)
        {
            m=a[i];
            printf("i = %d\n",i);
            printf("loc = %d\n",count+temp);
            data_hex[count+temp] = hex[m];
            printf("%c\n",hex[m]);
            temp++;

        }*/

        //printf("data_hex = %s\n",data_hex);
        //printf("vOut = %s\n",vOut);
        //src = (unsigned char *)c1;
        //printf("src = %s\n",src);
        //strcat(src, ic);
        //printf("src = %c\n", src);

        count= count + 1;
        printf("count = %d\n",count);
        //
        //printf("%s", c);
    }
    /* may check feof here to make a difference between eof and io failure -- network
       timeout for instance */
    //printf("data_hex_c = %s\n",data_hex);
    //printf("src = %hhx", src);
    fclose(file);

    return 0;
}
