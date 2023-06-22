#ifndef SRC_TWOFISHAPI_H_
#define SRC_TWOFISHAPI_H_


//#include "platform.h"
#include "stdio.h"
#include "stdlib.h"
#include "stdint.h"
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define XST_FAILURE 1L
#define XST_SUCCESS 0L



#define twofish_baseaddr 0x43C00000
#define twofish_highaddr 0x43c0ffff
#define map_size 0xffff


#define input 0xF
#define output 0x0

//Files
#define BUFFER_SIZE 17
#define BLOCK_SIZE 16
#define HEADER_SIZE 54
#define BITMAP_SIZE 200000	// bitmap size of a 256x256 image resolution

//User Defines
#define ENCMODE	0x01	//bit to select the encryption mode
#define KEYLD	0x2		//bit to specify the load of key
#define START	0x4		//bit to specify the start of encryption

//---------API interface---------

typedef uint8_t Twofish_Byte;
typedef Twofish_Byte Byte;

typedef struct{
	unsigned int uint32_key3;
	unsigned int uint32_key2;
	unsigned int uint32_key1;
	unsigned int uint32_key0;
}Twofish_key;


void Twofish_initialise();

void Twofish_finish();

void Twofish_prepare_key(Twofish_Byte *key, int key_len, Twofish_key *xkey);

void Twofish_encrypt(Twofish_key *xkey, Twofish_Byte *p, Twofish_Byte *c);

void Twofish_decrypt(Twofish_key *xkey, Twofish_Byte *c, Twofish_Byte *p);

// Encrypt the file
int Enc_file(const char *encryption_file, unsigned char* byteKey);

// Decrypt the file
int Dec_file(const char *encryption_file, unsigned char* byteKey);

// Encrypt image in CBC mode
int Enc_img(const char *input_filename, unsigned char* byteKey);

// Decrypt image in CBC mode
int Dec_img(const char *input_filename, unsigned char* byteKey);

// General application
int general_app(uint8_t, unsigned char* byteMessage, unsigned char* byteKey);

void hexToByteArray(const char* hexString, unsigned char* byteArray);


#endif /* SRC_TWOFISHAPI_H_ */
