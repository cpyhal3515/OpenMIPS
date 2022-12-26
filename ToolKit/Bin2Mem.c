/*
 * Xiang Li, olivercamel@gmail.com
 * Lin Zuo, superzuolin@gmail.com
 * Last Revised: 2008/06/28
 *
 * This is a converter tool written in C, which used to generate MIF
 * format files from Intel-HEX format. MIF format is used in ALTERA
 * Quartus to initialize on-chip RAM.
 *
 * The size of On-chip RAM is defined when it is created in Quartus.
 * Before using this converter, check if MIF_DEPTH and MIF_WIDTH
 * match the target On-chip RAM. Unfortunatly, so far only 32-bit
 * MIF_WIDTH is supported.
 *
 * Usage: ihex2mif.exe -f input.ihex -o output.mif
 */

#define MIF_DEPTH 8192
#define MIF_WIDTH 32

#include <stdlib.h>
#include <stdio.h>

char *option_invalid  = NULL;
char *option_file_in  = NULL;
char *option_file_out = NULL;

FILE *file_in_descriptor  = NULL;
FILE *file_out_descriptor = NULL;

void help_info(void) {
    printf("\n");
    printf("Binary to ModelSim mem.data Converter\n");
    printf("\n");
    printf("\n");
    printf("Usage: Bin2Mem.exe [options] file ...\n");
    printf("Options:\n");
    printf("  -h                    Help:   Display this information.\n");
    printf("  -f <Binary file>   Input:  Specify an intput Binary file.\n");
    printf("  -o <mem.data file>         Output: Specify an output mem.data file.\n");
    printf("\n");
    printf("Examples:\n");
    printf("  ./Bin2Mem.exe -f input.bin -o mem.data\n");
    printf("\n");
}

void exception_handler(int code) {
    switch (code) {
        case 0:
            break;
        case 10001:
            printf("Error (10001): No option recognized.\n");
            printf("Please specify at least one valid option.\n");
            printf("Try '-h' for more information.\n");
            break;
        case 10002:
            printf("Error (10002): Invalid option: %s\n", option_invalid);
            printf("Try '-h' for more information.\n");
            break;
        case 10003:
            printf("Error (10003): No input Binary file specified.\n");
            printf("Try '-h' for more information.\n");
            break;
        case 10004:
            printf("Error (10004): Cannot open file: %s\n", option_file_in);
            printf("Try '-h' for more information.\n");
            break;
        case 10005:
            printf("Error (10005): Cannot create file: %s\n", option_file_out);
            printf("Try '-h' for more information.\n");
            break;
        case 10006:
            printf("Error (10006): Binary file contains too much data to put into on-chip RAM.\n");
            break;
        default:
            break;
    }

    if (file_in_descriptor  != NULL) {
        fclose(file_in_descriptor);
    }
    if (file_out_descriptor != NULL) {
        fclose(file_out_descriptor);
    }
    exit(0);
}

int main(int argc, char **argv) {
 
    int i=0,j=0;
    unsigned char temp1,temp2,temp3,temp4;
    unsigned int option_flag = 0;


    while (argc > 0) {
        if (**argv == '-') {
            (*argv) ++;
            switch (**argv) {
                case 'f':
                    option_flag |= 0x4;
                    argv ++;
                    option_file_in = *argv;
                    argc --;
                    break;
                case 'o':
                    option_flag |= 0x8;
                    argv ++;
                    option_file_out = *argv;
                    argc --;
                    break;
                default:
                    option_flag |= 0x1;
                    (*argv) --;
                    option_invalid = *argv;
                    break;
            }
        }
        argv ++;
        argc --;
    }



    if (option_flag == 0) {
        exception_handler(10001);
    }

    if ((option_flag & 0x1) == 0x1) {
        exception_handler(10002);
    }

    if ((option_flag & 0x2) == 0x2) {
        help_info();
        exception_handler(0);
    }

    if ((option_flag & 0x4) != 0x4) {
        exception_handler(10003);
    }

    file_in_descriptor = fopen("inst_rom.bin", "rb");
    if (file_in_descriptor == NULL) {
        exception_handler(10004);
    }

    if ((option_flag & 0x8) != 0x8) {
        option_file_out = "mem.data";
    }

    file_out_descriptor = fopen(option_file_out, "w");
    if (file_out_descriptor == NULL) {
        exception_handler(10005);
    }


    
    while (!feof(file_in_descriptor)) {
         
            fscanf(file_in_descriptor, "%c", &temp1);
            fscanf(file_in_descriptor, "%c", &temp2);
            fscanf(file_in_descriptor, "%c", &temp3);
            fscanf(file_in_descriptor, "%c", &temp4);

            /*if(temp1!=255 && temp2!=255 && temp3 !=255 && temp4!=255)
            {*/
              fprintf(file_out_descriptor, "%02x", temp1);
              fprintf(file_out_descriptor, "%02x", temp2);
              fprintf(file_out_descriptor, "%02x", temp3);
              fprintf(file_out_descriptor, "%02x", temp4);
              fprintf(file_out_descriptor, "\n");
            //}
             


    }

    exception_handler(0);
    return 0;
}

