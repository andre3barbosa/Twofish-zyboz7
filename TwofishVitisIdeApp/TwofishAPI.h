/*
 * TwofishAPI.h
 *
 *  Created on: Jun 17, 2023
 *      Author: carlos & andre
 */

#ifndef SRC_TWOFISHAPI_H_
#define SRC_TWOFISHAPI_H_

#include <xparameters.h>
#include "xil_io.h"
#include "xil_types.h"
#include "platform.h"
#include "sleep.h"
#include "xsdps.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "ff.h"
#include "stdio.h"
#include "stdlib.h"


#define led_gpio XPAR_AXI_GPIO_0_DEVICE_ID
#define sw_gpio XPAR_AXI_GPIO_1_DEVICE_ID
#define twofishIP XPAR_TWOFISHIP_0_DEVICE_ID
#define twofish_baseaddr XPAR_TWOFISHAXIIP_0_S00_AXI_BASEADDR
#define input 0xF
#define output 0x0
#define BUFFER_SIZE 17
#define BLOCK_SIZE 16

#define HEADER_SIZE 54
#define BITMAP_SIZE 200000	// bitmap size of a 256x256 image resolution

//User Defines
#define ENCMODE	0x01	//bit to select the encryption mode
#define KEYLD	0x2		//bit to specify the load of key
#define START	0x4		//bit to specify the start of encryption

//API interface

typedef uint8_t Twofish_Byte;
typedef Twofish_Byte Byte;

typedef struct{
	unsigned int uint32_key3;
	unsigned int uint32_key2;
	unsigned int uint32_key1;
	unsigned int uint32_key0;
}Twofish_key;


void Twofish_initialise();

void Twofish_prepare_key(Twofish_Byte *key, int key_len, Twofish_key *xkey);

void Twofish_encrypt(Twofish_key *xkey, Twofish_Byte *p, Twofish_Byte *c);

void Twofish_decrypt(Twofish_key *xkey, Twofish_Byte *c, Twofish_Byte *p);

// Encrypt the file
int Enc_file(const char *encryption_file);

// Decrypt the file
int Dec_file(const char *encryption_file);

// Encrypt image in CBC mode
int Enc_img(const char *input_filename);

// Decrypt image in CBC mode
int Dec_img(const char *input_filename);

// General application
void general_app();



#endif /* SRC_TWOFISHAPI_H_ */
