#include <stdio.h>
#include <stdlib.h>

void generator(){
	FILE * fp;
	fp = fopen("code.txt", "w+");
	fprintf(fp, "xseg segment public´code´\n\tassume cs:xseg, ds:xseg, ss:xseg\n\torg 100h\nmain proc near\n\tcall near ptr program\n\tax,4C00h\n\tint 21h\nmain endp\n");
	fclose(fp);
}
