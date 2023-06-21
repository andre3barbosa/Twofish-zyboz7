#include "TwofishAPI.h"


// Functions
void Twofish_initialise()
{
	XGpio leds, switches;
	u32 iterator = 0;
	u32 sw_data = 0;
	u32 start = 0;

    XGpio_Initialize(&leds, led_gpio);
    XGpio_Initialize(&switches, sw_gpio);

	XGpio_SetDataDirection(&leds, 1, output);
	XGpio_SetDataDirection(&switches, 1, input);

	init_platform();


	// While the fpga switch enable is not on
	do{
		sw_data = XGpio_DiscreteRead(&switches, 1);	//get the switches value
		start = sw_data & 0x1;	//mask to the first switch
	}while(start==0);



 	//reseting
    for(iterator = 4; iterator <= 16; iterator = iterator + 4)
        {
    		Xil_Out32(twofish_baseaddr + iterator, 0x00000000);
        }
	for(iterator = 20; iterator <= 32; iterator = iterator + 4)
	    {
			Xil_Out32(twofish_baseaddr + iterator, 0x00000000);
	    }

	// Initial vector
	// da 39 a3 ee 5e 6b 4b 0d 32 55 bf ef 95 60 18 90
	unsigned int IV3 = 0xda39a3ee;
	unsigned int IV2 = 0x5e6b4b0d;
	unsigned int IV1 = 0x3255bfef;
	unsigned int IV0 = 0x95601890;


	// Assign initial vector values
	Xil_Out32(twofish_baseaddr + 56, IV3);
	Xil_Out32(twofish_baseaddr + 60, IV2);
	Xil_Out32(twofish_baseaddr + 64, IV1);
	Xil_Out32(twofish_baseaddr + 68, IV0);

	// Inform the user that the encryption system is on
	XGpio_DiscreteWrite(&leds, 1, 1);	//set the led to one

	xil_printf("Platform Initialized!\r\n");
}

void Twofish_prepare_key(Twofish_Byte *key, int key_len, Twofish_key *xkey)
{
	// Convert the 32-bit of the key to unsigned int
	xkey-> uint32_key3 = ((unsigned int)key[0] << 24) | ((unsigned int)key[1] << 16) | ((unsigned int)key[2] << 8) | (unsigned int)key[3];
	xkey-> uint32_key2 = ((unsigned int)key[4] << 24) | ((unsigned int)key[5] << 16) | ((unsigned int)key[6] << 8) | (unsigned int)key[7];
	xkey-> uint32_key1 = ((unsigned int)key[8] << 24) | ((unsigned int)key[9] << 16) | ((unsigned int)key[10] << 8) | (unsigned int)key[11];
	xkey-> uint32_key0 = ((unsigned int)key[12] << 24) | ((unsigned int)key[13] << 16) | ((unsigned int)key[14] << 8) | (unsigned int)key[15];
}

void Twofish_encrypt(Twofish_key *xkey, Twofish_Byte *p, Twofish_Byte *c)
{
	unsigned int plaintext3, plaintext2, plaintext1, plaintext0;
	unsigned int crypto3, crypto2, crypto1, crypto0;
	u32 idle = 0;	// when is on the ip is idle

	// Convert the 32-bit of the plaintext to unsigned int
	plaintext3 = ((unsigned int)p[0] << 24) | ((unsigned int)p[1] << 16) | ((unsigned int)p[2] << 8) | (unsigned int)p[3];
	plaintext2 = ((unsigned int)p[4] << 24) | ((unsigned int)p[5] << 16) | ((unsigned int)p[6] << 8) | (unsigned int)p[7];
	plaintext1 = ((unsigned int)p[8] << 24) | ((unsigned int)p[9] << 16) | ((unsigned int)p[10] << 8) | (unsigned int)p[11];
	plaintext0 = ((unsigned int)p[12] << 24) | ((unsigned int)p[13] << 16) | ((unsigned int)p[14] << 8) | (unsigned int)p[15];


	// Set the plaintext value
	Xil_Out32(twofish_baseaddr + 4, plaintext3);
	Xil_Out32(twofish_baseaddr + 8, plaintext2);
	Xil_Out32(twofish_baseaddr + 12, plaintext1);
	Xil_Out32(twofish_baseaddr + 16, plaintext0);

	// Set the key value
	Xil_Out32(twofish_baseaddr + 20, xkey-> uint32_key3);
	Xil_Out32(twofish_baseaddr + 24, xkey-> uint32_key2);
	Xil_Out32(twofish_baseaddr + 28, xkey-> uint32_key1);
	Xil_Out32(twofish_baseaddr + 32, xkey-> uint32_key0);

    // Load of key values
    Xil_Out32(twofish_baseaddr, KEYLD);

    // Enable the encryption mode
	Xil_Out32(twofish_baseaddr, ENCMODE | START);

	do{
		idle = Xil_In32(twofish_baseaddr+36);	//while the encryption is not over
	}while(idle == 0);


	// Get the values of the cyphertext
    crypto3 = Xil_In32(twofish_baseaddr+40);
    crypto2 = Xil_In32(twofish_baseaddr+44);
    crypto1 = Xil_In32(twofish_baseaddr+48);
	crypto0 = Xil_In32(twofish_baseaddr+52);


	// Convert 4x 32-bit words into one char's array
	c[0] = (Twofish_Byte)(crypto3 >> 24);
	c[1] = (Twofish_Byte)(crypto3 >> 16);
	c[2] = (Twofish_Byte)(crypto3 >> 8);
	c[3] = (Twofish_Byte)crypto3;

	c[4] = (Twofish_Byte)(crypto2 >> 24);
	c[5] = (Twofish_Byte)(crypto2 >> 16);
	c[6] = (Twofish_Byte)(crypto2 >> 8);
	c[7] = (Twofish_Byte)crypto2;

	c[8] = (Twofish_Byte)(crypto1 >> 24);
	c[9] = (Twofish_Byte)(crypto1 >> 16);
	c[10] = (Twofish_Byte)(crypto1 >> 8);
	c[11] = (Twofish_Byte)crypto1;

	c[12] = (Twofish_Byte)(crypto0 >> 24);
	c[13] = (Twofish_Byte)(crypto0 >> 16);
	c[14] = (Twofish_Byte)(crypto0 >> 8);
	c[15] = (Twofish_Byte)crypto0;

	//stop encryption
	Xil_Out32(twofish_baseaddr, 0x0);
}

void Twofish_decrypt(Twofish_key *xkey, Twofish_Byte *c, Twofish_Byte *p)
{
	long int plaintext3, plaintext2, plaintext1, plaintext0;
	long int crypto3, crypto2, crypto1, crypto0;
	u32 idle = 0;

	// Convert the 32-bit of the plaintext to unsigned int
	crypto3 = ((long int)c[0] << 24) | ((long int)c[1] << 16) | ((long int)c[2] << 8) | (long int)c[3];
	crypto2 = ((long int)c[4] << 24) | ((long int)c[5] << 16) | ((long int)c[6] << 8) | (long int)c[7];
	crypto1 = ((long int)c[8] << 24) | ((long int)c[9] << 16) | ((long int)c[10] << 8) | (long int)c[11];
	crypto0 = ((long int)c[12] << 24) | ((long int)c[13] << 16) | ((long int)c[14] << 8) | (long int)c[15];


	// Set the plaintext value
	Xil_Out32(twofish_baseaddr + 4, crypto3);
	Xil_Out32(twofish_baseaddr + 8, crypto2);
	Xil_Out32(twofish_baseaddr + 12, crypto1);
	Xil_Out32(twofish_baseaddr + 16, crypto0);

	// Set the key value
	Xil_Out32(twofish_baseaddr + 20, xkey-> uint32_key3);
	Xil_Out32(twofish_baseaddr + 24, xkey-> uint32_key2);
	Xil_Out32(twofish_baseaddr + 28, xkey-> uint32_key1);
	Xil_Out32(twofish_baseaddr + 32, xkey-> uint32_key0);

	// Load of key values
	Xil_Out32(twofish_baseaddr, KEYLD);

	// Enable the decryption mode
	Xil_Out32(twofish_baseaddr, START);

	do{
		idle = Xil_In32(twofish_baseaddr+36);	//while the encryption is not over
	}while(idle == 0);

	// Stop encryption
	Xil_Out32(twofish_baseaddr, 0x0);

	// Get the values of the cyphertext
	plaintext3 = Xil_In32(twofish_baseaddr+40);
	plaintext2 = Xil_In32(twofish_baseaddr+44);
	plaintext1 = Xil_In32(twofish_baseaddr+48);
	plaintext0 = Xil_In32(twofish_baseaddr+52);

	// Convert 4x 32-bit words into one char's array
	p[0] = (Twofish_Byte)(plaintext3 >> 24);
	p[1] = (Twofish_Byte)(plaintext3 >> 16);
	p[2] = (Twofish_Byte)(plaintext3 >> 8);
	p[3] = (Twofish_Byte)plaintext3;

	p[4] = (Twofish_Byte)(plaintext2 >> 24);
	p[5] = (Twofish_Byte)(plaintext2 >> 16);
	p[6] = (Twofish_Byte)(plaintext2 >> 8);
	p[7] = (Twofish_Byte)plaintext2;

	p[8] = (Twofish_Byte)(plaintext1 >> 24);
	p[9] = (Twofish_Byte)(plaintext1 >> 16);
	p[10] = (Twofish_Byte)(plaintext1 >> 8);
	p[11] = (Twofish_Byte)plaintext1;

	p[12] = (Twofish_Byte)(plaintext0 >> 24);
	p[13] = (Twofish_Byte)(plaintext0 >> 16);
	p[14] = (Twofish_Byte)(plaintext0 >> 8);
	p[15] = (Twofish_Byte)plaintext0;
}


int Enc_file(const char *encryption_file)
{
    // 128-bit key
	Twofish_Byte key[BLOCK_SIZE] = {0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00};

	// Data struct of the key
    Twofish_key enc_key;

    // Auxiliary local variables
	static char *encrypted_file = "EncryptedFile.txt";	//file name of the output encrypted text
    unsigned int bytesRead, BytesWr;
    unsigned int paddingSize;

    Twofish_Byte numBlocks;
	FIL file,fileEnc;
	FRESULT fat_result;
	FATFS FS_inst;

	// Auxiliary buffers to store the file's content
    Twofish_Byte block[256][BUFFER_SIZE+1];
    Twofish_Byte read_buffer[BUFFER_SIZE+1] __attribute__ ((aligned(32)));
    Twofish_Byte ciphertext[BLOCK_SIZE];

    // Initialize platform and twofish registers
    Twofish_initialise();

    // Prepare key
    Twofish_prepare_key(key, BLOCK_SIZE, &enc_key);


    //-------------------------------------
    // FILE encryption-
    //--------------------------------------

	//open the file
	fat_result = f_mount(&FS_inst, "0:/", 1);
	if (fat_result != 0)
	{
		xil_printf (" Error! f_mount returned %d\r\n", fat_result);
		return XST_FAILURE;
	}

	fat_result = f_open(&file, encryption_file,  FA_OPEN_ALWAYS | FA_READ);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d\r\n", fat_result);
		return XST_FAILURE;
	}
	fat_result = f_open(&fileEnc, encrypted_file,  FA_CREATE_ALWAYS | FA_WRITE);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d\r\n", fat_result);
		return XST_FAILURE;
	}

	// Position the file pointer to the end of the file
	fat_result = f_lseek(&file, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}
	fat_result = f_lseek(&fileEnc, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}

	// Calculate the number of blocks
	uint16_t sizef = f_size(&file);
	numBlocks = (sizef / BLOCK_SIZE) + 1;

	// Read and process each block
	for (int i = 0; i < numBlocks; i++) {
		// Read a block of data from the file
		fat_result = f_read(&file, (void*)read_buffer, BLOCK_SIZE, &bytesRead);
		if (fat_result != 0)
		{
			return XST_FAILURE;
		}


		// Check if padding is needed
		if (bytesRead < BLOCK_SIZE) {

			// Calculate the padding size
			paddingSize = BLOCK_SIZE - bytesRead;

			// Apply custom padding
			read_buffer[bytesRead] = 0xa;		// Last element of the buffer is 0xa
			for (int j = bytesRead+1; j < BLOCK_SIZE; j++) {
				read_buffer[j] = 0;				// To the rest of the buffer is assigned the value 0
			}
		}

		// Copy the buffer to the block
		for (int j = 0; j < BLOCK_SIZE; j++) {
			block[i][j] = (Twofish_Byte)read_buffer[j];
		}
	}

	// Encrypt each block
    for(int i = 0; i < numBlocks; i++)
    {
    	//Encrypt the 128-bit block cypher and store the value in cyphertext
    	Twofish_encrypt(&enc_key,block[i],ciphertext);

    	// Write in the output file
    	fat_result = f_write(&fileEnc, (const void*)ciphertext, BLOCK_SIZE, &BytesWr);

		if (fat_result != 0)
		{
			return XST_FAILURE;
		}
    }
    fat_result = f_close(&file);	// Close the read file

	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

	fat_result = f_close(&fileEnc);	// Close the write file
	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

    xil_printf("Finish File encryption!\r\n");
    return 0;
}

int Dec_file(const char *encryption_file){

	// 128-bit key
	Twofish_Byte key[BLOCK_SIZE] = {0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00};

	Twofish_key enc_key;

	const char encrypted_file[] = "pfile.txt";
	unsigned int bytesRead,BytesWr;

	Twofish_Byte numBlocks;
	FIL file;
	FIL fileEnc;
	FRESULT fat_result;
	FATFS FS_inst;


	Twofish_Byte block[256][BUFFER_SIZE+1];
	Twofish_Byte read_buffer[BUFFER_SIZE+1] __attribute__ ((aligned(32)));
	Twofish_Byte ciphertext[BLOCK_SIZE];

	// Initialize platform and twofish registers
	Twofish_initialise();

	// Prepare key
	Twofish_prepare_key(key, BLOCK_SIZE, &enc_key);


	//--------------------------------------
	// FILE decryption ---------------------
	//--------------------------------------


	fat_result = f_mount(&FS_inst, "0:/", 1);
	if (fat_result != 0)
	{
		xil_printf (" Error! f_mount returned %d\r\n", fat_result);
		return XST_FAILURE;
	}
	// Open the write file
	fat_result = f_open(&file, encryption_file,  FA_OPEN_ALWAYS | FA_READ);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d in ecryption file\r\n", fat_result);
		return XST_FAILURE;
	}
	// Open the read file
	fat_result = f_open(&fileEnc, encrypted_file,  FA_CREATE_NEW | FA_WRITE);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d in ecrypted file\r\n", fat_result);
		return XST_FAILURE;
	}
	//position the file pointer to the end of the file
	fat_result = f_lseek(&file, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}
	fat_result = f_lseek(&fileEnc, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}


	// Calculate the number of blocks
	uint16_t sizef = f_size(&file);
	numBlocks = (sizef / BLOCK_SIZE);

	// Read and process each block
	for (int i = 0; i < numBlocks; i++) {

		// Read a block of data from the file
		fat_result = f_read(&file, (void*)read_buffer, BLOCK_SIZE, &bytesRead);
		if (fat_result != 0)
		{
			return XST_FAILURE;
		}

		// Copy the buffer to the block
		for (int j = 0; j < BLOCK_SIZE; j++) {
			block[i][j] = (Twofish_Byte)read_buffer[j];
		}
	}



	// Remove extra padding
	for(int i = 0; i<16; i++)
	{
		if((block[numBlocks - 1][i] == 0xa) && (block[numBlocks - 1][i + 1] == 0))
		{
			block[numBlocks - 1][i] = -1;
			break;
		}
	}

	for(int i = 0; i < numBlocks; i++)
	{
		//Decrypt the 128-bit block cypher in message
		Twofish_decrypt(&enc_key,block[i],ciphertext);

		// Write the plaintext block in output file
		fat_result = f_write(&fileEnc, ciphertext, BLOCK_SIZE, &BytesWr);
		xil_printf("Bytes wr:%d\n",BytesWr);
		if (fat_result != 0)
		{
			return XST_FAILURE;
		}
	}

	// Close read file
	fat_result = f_close(&file);
	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

	// Close write file
	fat_result = f_close(&fileEnc);
	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

	xil_printf("Finish File decryption!\r\n");
	return 0;
}

int Enc_img(const char *input_filename)
{
	const char *output_filename = "EncOut.bmp";

	// 128-bit key
	Twofish_Byte key[16] = {0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00};

	Twofish_key enc_key;
	FIL rd_file;
	FIL wr_file;
	FRESULT fat_result;
	FATFS FS_inst;

	// Auxiliary variables
	unsigned int bytesRead,BytesWr;
	// Allocate memory for the bitmap
	static uint8_t bitmap_aux[BITMAP_SIZE] = {0};	//global memory

	// Initialize platform and twofish registers
	Twofish_initialise();

	// Prepare key
	Twofish_prepare_key(key, 16, &enc_key);

	Twofish_Byte ciphertext[17];

	//--------------------------------------
	// IMAGE encryption --------------------
	//--------------------------------------


	fat_result = f_mount(&FS_inst, "0:/", 1);
	if (fat_result != 0)
	{
		xil_printf (" Error! f_mount returned %d\r\n", fat_result);
		return XST_FAILURE;
	}

	//open the read file
	fat_result = f_open(&rd_file, input_filename,  FA_OPEN_ALWAYS | FA_READ);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d in ecryption file\r\n", fat_result);
		return XST_FAILURE;
	}
	//open the write file
	fat_result = f_open(&wr_file, output_filename, FA_OPEN_ALWAYS | FA_WRITE);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d in ecrypted file\r\n", fat_result);
		return XST_FAILURE;
	}

	// Position the file pointer to the end of the file
	fat_result = f_lseek(&rd_file, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}
	fat_result = f_lseek(&wr_file, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}

	// Calculate the number of blocks
	long int bitmap_size = f_size(&rd_file);

	// Points the bitmap pointer to the global array of data
	uint8_t *bitmap = (uint8_t *)bitmap_aux;
	if (bitmap == NULL) {
		xil_printf("Failed to allocate memory for bitmap\n");
		fat_result = f_close(&rd_file);
		if (fat_result != 0)
		{
		return XST_FAILURE;
		}
		return 1;
	}


	// Read the bitmap
	fat_result  = f_read(&rd_file, bitmap, bitmap_size, &bytesRead);
	if (bytesRead != (size_t)bitmap_size) {
		xil_printf("Failed to read file\n");
		// Close file
		fat_result = f_close(&rd_file);
		if (fat_result != 0)
		{
		return XST_FAILURE;
		}
		return 1;
	}

	// Close file
	fat_result = f_close(&rd_file);
	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

	// Exclude the header from the block conversion
	size_t data_size = bitmap_size - 54;
	size_t block_count = data_size / BLOCK_SIZE;

	// Encrypt bitmap
	uint8_t aux_block[BLOCK_SIZE+1];

	for (size_t i = 0; i < block_count; i++) {
		for (size_t j = 0; j < BLOCK_SIZE; j++) {
			aux_block[j] = bitmap[54 + i * BLOCK_SIZE + j];		// Get 16-bytes from bitmap and store in aux_block variable
		}
		Twofish_encrypt(&enc_key, aux_block, ciphertext);		// Encrypt the block

		for (size_t j = 0; j < BLOCK_SIZE; j++) {
			bitmap[54 + i * BLOCK_SIZE + j] = ciphertext[j];	// Update the bitmap with the encrypted block
		}
	}

	// Write the encrypted bitmap to the new file
	fat_result = f_write(&wr_file,bitmap, bitmap_size, &BytesWr);
	if (BytesWr != bitmap_size) {
		xil_printf("Failed to write file\n");
	}
	else if (fat_result != 0)
	{
		return XST_FAILURE;
	}

	 // Close file
	fat_result = f_close(&wr_file);
	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

	xil_printf("Image encryption over!\r\n");

	return 0;
}

int Dec_img(const char *input_filename)
{
	const char *output_filename = "DecOut.bmp";

	// 128-bit key
	Twofish_Byte key[16] = {0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00,
							0x00, 0x00, 0x00, 0x00};

	Twofish_key enc_key;
	FIL rd_file;
	FIL wr_file;
	FRESULT fat_result;
	FATFS FS_inst;
	Twofish_Byte plaintext[BLOCK_SIZE];

	// Allocate memory for the bitmap
	static uint8_t bitmap_aux[BITMAP_SIZE] = {0};	//global memory

	unsigned int bytesRead,BytesWr;

	// Initialize platform and twofish registers
	Twofish_initialise();

	// Prepare key
	Twofish_prepare_key(key, BLOCK_SIZE, &enc_key);


	//--------------------------------------
	// IMAGE decryption --------------------
	//--------------------------------------


	fat_result = f_mount(&FS_inst, "0:/", 1);
	if (fat_result != 0)
	{
		xil_printf (" Error! f_mount returned %d\r\n", fat_result);
		return XST_FAILURE;
	}

	//open the read file located in sd card
	fat_result = f_open(&rd_file, input_filename,  FA_OPEN_ALWAYS | FA_READ);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d in ecryption file\r\n", fat_result);
		return XST_FAILURE;
	}
	//open the write file located in sd card
	fat_result = f_open(&wr_file, output_filename,  FA_CREATE_NEW | FA_WRITE);
	if (fat_result != 0)
	{
		xil_printf(" Error! f_open returned %d in ecrypted file\r\n", fat_result);
		return XST_FAILURE;
	}

	// Position the file pointer to the end of the file
	fat_result = f_lseek(&rd_file, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}
	fat_result = f_lseek(&wr_file, 0);
	if(fat_result != 0)
	{
		xil_printf("lseek returned %d \r\n", fat_result);
		return XST_FAILURE;
	}

	// Calculate the number of blocks
	long int bitmap_size = f_size(&rd_file);

	// Points the bitmap pointer to the global array of data
	uint8_t *bitmap = (uint8_t *)bitmap_aux;
	if (bitmap == NULL) {
		xil_printf("Failed to allocate memory for bitmap\n");
		fat_result = f_close(&rd_file);
		if (fat_result != 0)
		{
		return XST_FAILURE;
		}
		return 1;
	}


	// Read the bitmap
	fat_result  = f_read(&rd_file, bitmap, bitmap_size, &bytesRead);
	if (bytesRead != (size_t)bitmap_size) {
		xil_printf("Failed to read file\n");
		// Close file
		fat_result = f_close(&rd_file);
		if (fat_result != 0)
		{
		return XST_FAILURE;
		}
		return 1;
	}

	// Close read file
	fat_result = f_close(&rd_file);
	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

	// Exclude the header from the block conversion
	size_t data_size = bitmap_size - HEADER_SIZE;
	size_t block_count = data_size / BLOCK_SIZE;


	// Decrypt bitmap
	uint8_t aux_block[BLOCK_SIZE];

	for (size_t i = 0; i < block_count; i++) {
		for (size_t j = 0; j < BLOCK_SIZE; j++) {
			aux_block[j] = bitmap[HEADER_SIZE + i * BLOCK_SIZE + j];		// Get 16-bytes from bitmap and store in aux_block variable
		}

		Twofish_decrypt(&enc_key, aux_block, plaintext);					// Decrypt the block
		for (size_t j = 0; j < BLOCK_SIZE; j++) {
			bitmap[HEADER_SIZE + i * BLOCK_SIZE + j] = plaintext[j];		// Update the bitmap with decrypted block
		}
	}

	// Write the encrypted bitmap to the new file
	fat_result = f_write(&wr_file,bitmap, bitmap_size, &BytesWr);
	if (BytesWr != bitmap_size) {
		xil_printf("Failed to write file\n");
	}
	else if (fat_result != 0)
	{
		return XST_FAILURE;
	}

	 // Close write file
	fat_result = f_close(&wr_file);
	if (fat_result != 0)
	{
	return XST_FAILURE;
	}

	xil_printf("Image decryption over!\r\n");

	return 0;
}

/*
 * This function execute an individual encryption/decryption
 */
void general_app(){
    // Initialize the Twofish implementation
    Twofish_initialise();

    // Define a key and a message to encrypt
    Twofish_Byte key[16] = {0x00};
    Twofish_Byte message[16] = {0x00};

    // Prepare the key for encryption
    Twofish_key enc_key;
    Twofish_prepare_key(key, 16, &enc_key);

    // Print the key
    printf("Key: ");
    for (int i = 0; i < 16; i++) {
        printf("%02x", key[i]);
    }
    printf("\n");

    // Encrypt the message
    Twofish_Byte ciphertext[16];
    Twofish_encrypt(&enc_key, message, ciphertext);

    // Print the message
    xil_printf("Message: ");
    for (int i = 0; i < 16; i++) {
        xil_printf("%02x ", message[i]);
    }
    xil_printf("\n");

    //Print the ciphertext
	xil_printf("Cypher: ");
	for (int i = 0; i < 16; i++) {
		xil_printf("%02x ", ciphertext[i]);
	}
	xil_printf("\n");
    Twofish_encrypt(&enc_key, message, ciphertext);
    //Print the ciphertext
    xil_printf("Message: ");
    for (int i = 0; i < 16; i++) {
        xil_printf("%02x ", message[i]);
    }
    xil_printf("\n");

    //Print the ciphertext
	xil_printf("Cypher: ");
	for (int i = 0; i < 16; i++) {
		xil_printf("%02x ", ciphertext[i]);
	}
	xil_printf("\n");

	/*
	 * ------- Decryption ----------

    // Prepare the key for decryption
    Twofish_key dec_key;
    Twofish_prepare_key(key, 16, &dec_key);

    // Decrypt the ciphertext
    Twofish_Byte decrypted[16];
    Twofish_encrypt(&dec_key, message, decrypted);
    //decrypted[16] = '\0';

	//Print the ciphertext
	xil_printf("Plaintext: ");
	for (int i = 0; i < 16; i++) {
		printf("%02x ", decrypted[i]);
	}
	printf("\n");

     Print the decrypted message
    printf("Decrypted message: %s\n", decrypted);

    // Check if the decrypted message matches the original message
    if (strcmp((char*)message, (char*)decrypted) == 0) {
        printf("Decryption successful!\n");
    } else {
        printf("Decryption failed.\n");
    }
     */
}
