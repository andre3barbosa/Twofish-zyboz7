#include "TwofishAPI.h"
#include "time.h"
#include "string.h"

volatile unsigned int *virt_addr;
int fd;
void *map_base;

// Functions
void Twofish_initialise()
{
	uint32_t iterator = 0;

    /* Open memory */
    fd = open("/dev/mem", O_RDWR);
    if (fd < 0) {
        printf("Can't open /dev/mem\n");
        printf("Try with sudo\n");
        //return -1;
    }

    /* Map memory */
    map_base = mmap(NULL, map_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, twofish_baseaddr);
    if (map_base == NULL) {
        printf("Can't mmap\n");
        //return -1;
    }

    /* Write memory */
	//printf("Start Writing\n");
	virt_addr = (volatile unsigned int *)map_base;


 	//reseting
    for(iterator = 4; iterator <= 16; iterator = iterator + 4)
        {
    		virt_addr[iterator] = 0x00000000;
        }
	for(iterator = 20; iterator <= 32; iterator = iterator + 4)
	    {
			virt_addr[iterator] = 0x00000000;
	    }

	// Initial vector
	// da 39 a3 ee 5e 6b 4b 0d 32 55 bf ef 95 60 18 90
	unsigned int IV3 = 0xda39a3ee;
	unsigned int IV2 = 0x5e6b4b0d;
	unsigned int IV1 = 0x3255bfef;
	unsigned int IV0 = 0x95601890;


	// Assign initial vector values
	virt_addr[14] = IV3;
	virt_addr[15] = IV2;
	virt_addr[16] = IV1;
	virt_addr[17] = IV0;

}

void Twofish_finish(){
	// Unmap the memory space
	munmap(map_base, map_size);
	// Close the file
	close(fd);
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
	uint32_t idle = 0;	// when is on the ip is idle

	// Convert the 32-bit of the plaintext to unsigned int
	plaintext3 = ((unsigned int)p[0] << 24) | ((unsigned int)p[1] << 16) | ((unsigned int)p[2] << 8) | (unsigned int)p[3];
	plaintext2 = ((unsigned int)p[4] << 24) | ((unsigned int)p[5] << 16) | ((unsigned int)p[6] << 8) | (unsigned int)p[7];
	plaintext1 = ((unsigned int)p[8] << 24) | ((unsigned int)p[9] << 16) | ((unsigned int)p[10] << 8) | (unsigned int)p[11];
	plaintext0 = ((unsigned int)p[12] << 24) | ((unsigned int)p[13] << 16) | ((unsigned int)p[14] << 8) | (unsigned int)p[15];


	// Set the plaintext value
	virt_addr[1] = plaintext3;
	virt_addr[2] = plaintext2;
	virt_addr[3] = plaintext1;
	virt_addr[4] = plaintext0;

	// Set the key value
	virt_addr[5] = 	xkey-> uint32_key3;
	virt_addr[6] =	xkey-> uint32_key2;
	virt_addr[7] =	xkey-> uint32_key1;
	virt_addr[8] =	xkey-> uint32_key0;

    // Load of key values
    virt_addr[0] =  KEYLD;

    // Enable the encryption mode
	virt_addr[0] = ENCMODE | START;

	do{
		idle = virt_addr[9];	//while the encryption is not over
	}while(idle == 0);


	// Get the values of the cyphertext
    crypto3 = virt_addr[10];
    crypto2 = virt_addr[11];
    crypto1 = virt_addr[12];
	crypto0 = virt_addr[13];


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
	virt_addr[0] = 0x0;
}

void Twofish_decrypt(Twofish_key *xkey, Twofish_Byte *c, Twofish_Byte *p)
{
	long int plaintext3, plaintext2, plaintext1, plaintext0;
	long int crypto3, crypto2, crypto1, crypto0;
	uint32_t idle = 0;

	// Convert the 32-bit of the plaintext to unsigned int
	crypto3 = ((long int)c[0] << 24) | ((long int)c[1] << 16) | ((long int)c[2] << 8) | (long int)c[3];
	crypto2 = ((long int)c[4] << 24) | ((long int)c[5] << 16) | ((long int)c[6] << 8) | (long int)c[7];
	crypto1 = ((long int)c[8] << 24) | ((long int)c[9] << 16) | ((long int)c[10] << 8) | (long int)c[11];
	crypto0 = ((long int)c[12] << 24) | ((long int)c[13] << 16) | ((long int)c[14] << 8) | (long int)c[15];


	// Set the plaintext value
	virt_addr[1] = crypto3;
	virt_addr[2] = crypto2;
	virt_addr[3] = crypto1;
	virt_addr[4] = crypto0;

	// Set the key value
	virt_addr[5] = xkey-> uint32_key3;
	virt_addr[6] = xkey-> uint32_key2;
	virt_addr[7] = xkey-> uint32_key1;
	virt_addr[8] = xkey-> uint32_key0;

	 // Load of key values
	    virt_addr[0] =  KEYLD;

	// Enable the decryption mode
	    virt_addr[0] =  START;

	do{
		idle = virt_addr[9];	//while the encryption is not over
	}while(idle == 0);

	// Stop encryption
	virt_addr[0] = 0x0;

	// Get the values of the cyphertext
	plaintext3 = virt_addr[10];
	plaintext2 = virt_addr[11];
	plaintext1 = virt_addr[12];
	plaintext0 = virt_addr[13];

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


int Enc_file(const char *encryption_file, unsigned char* byteKey)
{

	clock_t start, end;
	int n_ticks;

	// Data struct of the key
    Twofish_key enc_key;

    // Auxiliary local variables
	static char *encrypted_file = "EncryptedFile.txt";	//file name of the output encrypted text
    unsigned int bytesRead, BytesWr;
    unsigned int paddingSize;

    Twofish_Byte numBlocks;
	FILE *file;
	FILE *fileEnc;

	// Auxiliary buffers to store the file's content
    Twofish_Byte block[256][BUFFER_SIZE+1];
    Twofish_Byte read_buffer[BUFFER_SIZE+1] __attribute__ ((aligned(32)));
    Twofish_Byte ciphertext[BLOCK_SIZE+1];

    // Initialize platform and twofish registers
    Twofish_initialise();

    // Prepare key
    Twofish_prepare_key(byteKey, BLOCK_SIZE, &enc_key);


    //-------------------------------------
    // FILE encryption-
    //--------------------------------------

    // Open the file
    file = fopen(encryption_file, "rb");
    if (file == NULL) {
        printf("Error! Unable to open file: %s\n", encryption_file);
        return -1;
    }

    fileEnc = fopen(encrypted_file, "wb");
    if (fileEnc == NULL) {
        printf("Error! Unable to open file: %s\n", encrypted_file);
        fclose(file);
        return -1;
    }

    // Position the file pointer to the end of the file
	fseek(file, 0, SEEK_SET);
	fseek(fileEnc, 0, SEEK_SET);

	// Calculate the number of blocks
	uint16_t sizef;
	fseek(file, 0, SEEK_END);
	sizef = ftell(file);
	fseek(file, 0, SEEK_SET);
	numBlocks = (sizef / BLOCK_SIZE) + 1;

	// Read and process each block
	    for (int i = 0; i < numBlocks; i++) {
	        // Read a block of data from the file
	        bytesRead = fread(read_buffer, 1, BLOCK_SIZE, file);

	        // Check if padding is needed
	        if (bytesRead < BLOCK_SIZE) {
	            // Calculate the padding size
	            paddingSize = BLOCK_SIZE - bytesRead;

	            // Apply custom padding
	            read_buffer[bytesRead] = 0xa; // Last element of the buffer is 0xa
	            for (int j = bytesRead + 1; j < BLOCK_SIZE; j++) {
	                read_buffer[j] = 0; // To the rest of the buffer is assigned the value 0
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
    	BytesWr = fwrite(ciphertext, 1, BLOCK_SIZE, fileEnc);

        if (BytesWr != BLOCK_SIZE) {
                printf("Error! Unable to write encrypted data to file.\n");
                fclose(file);
                fclose(fileEnc);
                return -1;
        }
    }

	fclose(file);    // Close the read file
	fclose(fileEnc); // Close the write file

	Twofish_finish();
	printf("Finish File encryption!\n\n");
	return 0;
}

int Dec_file(const char *encryption_file, unsigned char* byteKey){

	Twofish_key enc_key;

	const char encrypted_file[] = "DecryptedFile.txt";
	unsigned int bytesRead,BytesWr;

	Twofish_Byte numBlocks;
	FILE *file;
	FILE *fileEnc;

	Twofish_Byte block[256][BUFFER_SIZE+1];
	Twofish_Byte read_buffer[BUFFER_SIZE+1] __attribute__ ((aligned(32)));
	Twofish_Byte ciphertext[BLOCK_SIZE];

	// Initialize platform and twofish registers
	Twofish_initialise();

	// Prepare key
	Twofish_prepare_key(byteKey, BLOCK_SIZE, &enc_key);


	//--------------------------------------
	// FILE decryption ---------------------
	//--------------------------------------

	// Open the write file
	file = fopen(encryption_file, "rb");
	if (file == NULL) {
		printf("Error! Unable to open file: %s\n", encryption_file);
		return -1;
	}

	fileEnc = fopen(encrypted_file, "wb");
	if (fileEnc == NULL) {
		printf("Error! Unable to open file: %s\n", encrypted_file);
		fclose(file);
		return -1;
	}

	// Position the file pointer to the end of the file
	fseek(file, 0, SEEK_SET);
	fseek(fileEnc, 0, SEEK_SET);

	 // Calculate the number of blocks
	uint16_t sizef;
	fseek(file, 0, SEEK_END);
	sizef = ftell(file);
	fseek(file, 0, SEEK_SET);
	numBlocks = sizef / BLOCK_SIZE;

	// Read and process each block
	for (int i = 0; i < numBlocks; i++) {

		// Read a block of data from the file
		bytesRead = fread(read_buffer, 1, BLOCK_SIZE, file);

		// Copy the buffer to the block
		for (int j = 0; j < BLOCK_SIZE; j++) {
			block[i][j] = (Twofish_Byte)read_buffer[j];
		}
	}

	// Remove extra padding
	for (int i = 0; i < 16; i++) {
		if ((block[numBlocks - 1][i] == 0xa) && (block[numBlocks - 1][i + 1] == 0)) {
			block[numBlocks - 1][i] = -1;
			break;
		}
	}


	for(int i = 0; i < numBlocks; i++)
	{

		//Decrypt the 128-bit block cypher in message
		Twofish_decrypt(&enc_key,block[i],ciphertext);

		// Write the plaintext block in the output file
		BytesWr = fwrite(ciphertext, 1, BLOCK_SIZE, fileEnc);
		if (BytesWr != BLOCK_SIZE) {
			printf("Error! Unable to write decrypted data to file.\n");
			fclose(file);
			fclose(fileEnc);
			return -1;
		}
	}

	fclose(file);    // Close the read file
	fclose(fileEnc); // Close the write file

	Twofish_finish();
	printf("Finish File decryption!\n\n");
	return 0;
}

int Enc_img(const char *input_filename, unsigned char* byteKey)
{
	const char *output_filename = "EncryptedImage.bmp";

	Twofish_key enc_key;
	FILE *rd_file;
	FILE *wr_file;

	// Auxiliary variables
	unsigned int bytesRead,BytesWr;
	// Allocate memory for the bitmap
	static uint8_t bitmap_aux[BITMAP_SIZE] = {0};	//global memory

	// Initialize platform and twofish registers
	Twofish_initialise();

	// Prepare key
	Twofish_prepare_key(byteKey, 16, &enc_key);

	Twofish_Byte ciphertext[17];

	//--------------------------------------
	// IMAGE encryption --------------------
	//--------------------------------------

	// Open the read file
	rd_file = fopen(input_filename, "rb");
	if (rd_file == NULL) {
		printf("Error! Unable to open file: %s\n", input_filename);
		return -1;
	}

	// Open the write file
	wr_file = fopen(output_filename, "wb");
	if (wr_file == NULL) {
		printf("Error! Unable to open file: %s\n", output_filename);
		fclose(rd_file);
		return -1;
	}

	// Position the file pointer to the end of the file
	fseek(rd_file, 0, SEEK_SET);
	fseek(wr_file, 0, SEEK_SET);

	 // Calculate the number of blocks
	long int bitmap_size;
	fseek(rd_file, 0, SEEK_END);
	bitmap_size = ftell(rd_file);
	fseek(rd_file, 0, SEEK_SET);



	// Points the bitmap pointer to the global array of data
	uint8_t *bitmap = (uint8_t *)bitmap_aux;
	if (bitmap == NULL) {
		printf("Failed to allocate memory for bitmap\n");
		fclose(rd_file);
		fclose(wr_file);
		return -1;
	}


	// Read the bitmap
	bytesRead = fread(bitmap, 1, bitmap_size, rd_file);
	if (bytesRead != (size_t)bitmap_size) {
		printf("Failed to read file\n");
		fclose(rd_file);
		fclose(wr_file);
		return -1;
	}

	fclose(rd_file); // Close the read file

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
	BytesWr = fwrite(bitmap, 1, bitmap_size, wr_file);
	if (BytesWr != bitmap_size) {
		printf("Failed to write file\n");
		fclose(wr_file);
		return -1;
	}

	fclose(wr_file); // Close the write file

	Twofish_finish();
	printf("Image encryption over!\r\n\n");

	return 0;
}

int Dec_img(const char *input_filename, unsigned char* byteKey)
{
	const char *output_filename = "DecryptedImage.bmp";

	Twofish_key enc_key;
	FILE *rd_file;
	FILE *wr_file;

	Twofish_Byte plaintext[BLOCK_SIZE];

	// Allocate memory for the bitmap
	static uint8_t bitmap_aux[BITMAP_SIZE] = {0};	//global memory

	unsigned int bytesRead,BytesWr;

	// Initialize platform and twofish registers
	Twofish_initialise();

	// Prepare key
	Twofish_prepare_key(byteKey, BLOCK_SIZE, &enc_key);


	//--------------------------------------
	// IMAGE decryption --------------------
	//--------------------------------------


	// Open the read file located on the disk
	rd_file = fopen(input_filename, "rb");
	if (rd_file == NULL) {
		printf("Error! Failed to open the input file.\n");
		return -1;
	}

	// Open the write file located on the disk
	wr_file = fopen(output_filename, "wb");
	if (wr_file == NULL) {
		printf("Error! Failed to open the output file.\n");
		fclose(rd_file);
		return -1;
	}

	// Calculate the number of blocks
	fseek(rd_file, 0, SEEK_END);
	long int bitmap_size = ftell(rd_file);
	fseek(rd_file, 0, SEEK_SET);

	// Points the bitmap pointer to the global array of data
	uint8_t *bitmap = (uint8_t *)bitmap_aux;
	if (bitmap == NULL) {
		printf("Failed to allocate memory for bitmap\n");
		fclose(rd_file);
		fclose(wr_file);
		return -1;
	}

	// Read the bitmap
	bytesRead = fread(bitmap, 1, bitmap_size, rd_file);
	if (bytesRead != (size_t)bitmap_size) {
		printf("Failed to read file\n");
		fclose(rd_file);
		fclose(wr_file);
		return -1;
	}

	// Close read file
	fclose(rd_file);


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

	// Write the decrypted bitmap to the new file
	fseek(wr_file, 0, SEEK_SET);
	BytesWr = fwrite(bitmap, 1, bitmap_size, wr_file);
	if (BytesWr != bitmap_size) {
		printf("Failed to write file\n");
	}

	 // Close write file
	fclose(wr_file);

	Twofish_finish();
	printf("Image decryption over!\r\n\n");

	return 0;
}

/*
 * This function execute an individual encryption/decryption
 */
int general_app(uint8_t i_mode, unsigned char* byteMessage, unsigned char* byteKey){

	clock_t start, end;
		int n_ticks;

	// Initialize the Twofish implementation
    Twofish_initialise();

    // Prepare the key for encryption
	if(i_mode == 1)
	{
		Twofish_key enc_key;
		Twofish_prepare_key(byteKey, 16, &enc_key);

	   // Print the key
	   printf("Key: ");
	   for (int i = 0; i < 16; i++) {
	       printf("%02x", byteKey[i]);
	   }
	   printf("\n");

		// Encrypt the message
		Twofish_Byte ciphertext[16];
		Twofish_encrypt(&enc_key, byteMessage, ciphertext);

		//Print the message
		printf("Message: ");
		for (int i = 0; i < 16; i++) {
			printf("%02x ", byteMessage[i]);
		}
		printf("\n");

		//Print the ciphertext
		printf("Cypher: ");
		for (int i = 0; i < 16; i++) {
			printf("%02x ", ciphertext[i]);
		}
		printf("\n");

		printf("Encryption Over!\n\n");

	}
	else{
		//	  ------- Decryption ----------


		// Prepare the key for decryption
		Twofish_key dec_key;
		Twofish_prepare_key(byteKey, 16, &dec_key);

		// Decrypt the ciphertext
		Twofish_Byte decrypted[16];
		Twofish_encrypt(&dec_key, byteMessage, decrypted);
		decrypted[16] = '\0';

		//Print the message
		printf("Message: ");
		for (int i = 0; i < 16; i++) {
			printf("%02x ", byteMessage[i]);
		}
		printf("\n");

		//Print the ciphertext
		printf("Plaintext: ");
		for (int i = 0; i < 16; i++) {
			printf("%02x ", decrypted[i]);
		}
		printf("\n");

		printf("Decryption Over!\n\n");
	}


	return n_ticks;
}

void hexToByteArray(const char* hexString, unsigned char* byteArray) {
    size_t length = strlen(hexString);
    size_t byteLength = length / 2;

    for (size_t i = 0; i < byteLength; i++) {
        sscanf(hexString + (2 * i), "%2hhx", &byteArray[i]);
    }
}


