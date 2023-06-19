#include "TwofishAPI.h"


int main()
{
//	char FileName[15] = "Result.txt";
//	const char *encryption_file = (char *)FileName;
	//const char *input_filename = "tux.bmp";
	const char *input_filename = "EncOut6.bmp";

	//Encrypt file
	//Enc_file(encryption_file);
	//Dec_file(encryption_file);
	//Enc_img(input_filename);
	Dec_img(input_filename);

	//general_app();

    cleanup_platform();
    return XST_SUCCESS;
}






