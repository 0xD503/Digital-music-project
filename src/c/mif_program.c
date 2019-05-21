#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <string.h>

#define NUMBER_OF_ELEMENTS	4096


int main (void)
{
	FILE *wavFilePtr;
	FILE *mif;
	uint8_t *fileBufer;
	size_t i;
	size_t bytesNum;

	fileBufer = (uint8_t *) malloc(sizeof(*fileBufer) * NUMBER_OF_ELEMENTS);

	wavFilePtr = fopen("./8k16bitpcm128kbps.wav", "rb+");
	mif = fopen("./8k16bitpcm128kbps.dat", "w+");
	bytesNum = fread(fileBufer, sizeof(*fileBufer), NUMBER_OF_ELEMENTS, wavFilePtr);
	//fwrite(fileBufer, sizeof(*fileBufer), NUMBER_OF_ELEMENTS, mif);
	for (i = 0; i < bytesNum; i++)	fprintf(mif, (uint8_t *) fileBufer[i]);
	fclose(mif);
	fclose(wavFilePtr);

	free(fileBufer);

	return (0);
}

