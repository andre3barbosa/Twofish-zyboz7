#include "TwofishAPI.h"
#include "time.h"

#define MAXNAMESIZE 32

int main()
{
	uint8_t opt;            			// Store the user menu option
    uint8_t i_filename[MAXNAMESIZE];	// Input filename

    char hexMessage[33];
    unsigned char byteMessage[BLOCK_SIZE];

    char hexKey[33];
    unsigned char byteKey[BLOCK_SIZE];

    printf("Welcome to Twofish!\n\n\t-- Menu Twofish --\n1- Enc/Dec one block\n2- Enc/dec one file\n3- Enc/dec one image\n\nChoose one application available: ");
    scanf("%d", &opt);


    switch(opt){
        case 1:
            printf("You choose Enc/Dec one block! What do you want do do?\n");
            printf("1- Encrypt\n");
            printf("2- Decrypt\n");
            printf("->");
            scanf("%d", &opt);

            printf("Message: ");
            scanf("%32s", hexMessage);
            hexToByteArray(hexMessage, byteMessage);
            printf("Key: ");
            scanf("%32s", hexKey);
            hexToByteArray(hexMessage, byteKey);

            printf("Starting encryption ...\n\n");

			if(opt == 1 || opt == 2)
                    //Call the one block encryption
					general_app(opt, byteMessage, byteKey);
			else
                printf("You choose an invalid option! Choose another one ->");

        break ;
        case 2:
            printf("You choose Enc/dec one file! What do you want do do?\n");
            printf("1- Encrypt\n");
            printf("2- Decrypt\n");
            printf("->");
            scanf("%d", &opt);
            printf("Now put the name of the input file: ->");
            scanf("%s", i_filename);

            printf("Key: ");
            scanf("%32s", hexKey);
            hexToByteArray(hexMessage, byteKey);

            printf("Starting encryption ...\n\n");
            switch(opt)
            {
                case 1:
                    //Call the file encryption
					Enc_file(i_filename, byteKey);
                break;
                case 2:
                    //Call the file decryption
					Dec_file(i_filename, byteKey);
                break;
                default:
                printf("You choose an invalid option! Choose another one ->");
            }

        break

        ;
        case 3:
            printf("You choose Enc/dec one image! What do you want do do?\n");
            printf("1- Encrypt\n");
            printf("2- Decrypt\n");
            printf("->");
            scanf("%d", &opt);
            printf("Now put the name of the input file: ->");
            scanf("%s", i_filename);

            printf("Key: ");
            scanf("%32s", hexKey);
            hexToByteArray(hexMessage, byteKey);

            printf("Starting encryption ...\n\n");

            switch(opt)
            {
                case 1:
                    //Call the one block encryption
					Enc_img(i_filename, byteKey);
                break;
                case 2:
                    //Call the one block decryption
					Dec_img(i_filename, byteKey);
                break;
                default:
                printf("You choose an invalid option! Choose another one ->");
            }

        break;
        default:
        printf("You choose an invalid option! Choose another one ->");

    }



return XST_SUCCESS;

}
