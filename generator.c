#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "generator.h"
#include "quads.h"

void generator(){
	int i;
	FILE * fp, * fp2;

	fp = fopen("code.txt", "w+");
	fp2 = fopen("quads.txt", "r");
	fprintf(fp, "xseg segment public´code´\n\tassume cs:xseg, ds:xseg, ss:xseg\n\torg 100h\nmain proc near\n\tcall near ptr program\n\tmov ax,4C00h\n\tint 21h\nmain endp\n");

	for(i = 0; i < nextquad; i++){
		fprintf(fp, "@%d:\n", i);
		generate(consume_quad(fp2), fp);
		fprintf(fp, "\n");
	}

	fprintf(fp, "xseg ends\n\tend main\n");
	fclose(fp);
}

Interpreted_quad consume_quad(FILE * fp){
	int num;
	char quad[256], arg1[256], arg2[256], dest[256];
	Interpreted_quad interpreted_quad;

	fscanf(fp, "%d: %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n]\n", &num, quad, arg1, arg2, dest);

	interpreted_quad.id   = num;
	interpreted_quad.quad = strdup(quad);
	interpreted_quad.arg1 = strdup(arg1);
	interpreted_quad.arg2 = strdup(arg2);
	interpreted_quad.dest = strdup(dest);

	return interpreted_quad;
}


void generate(Interpreted_quad quad, FILE * fp){
	char * temp_label, * temp_name, * temp_endof;

	if (strcmp(quad.quad, ":=") == 0){
		load("R", quad.arg1, fp);
		store("R", quad.dest, fp);
	}
	else if ((strcmp(quad.quad, "+") == 0) || (strcmp(quad.quad, "-") == 0)){
		load("ax", quad.arg1, fp);
		load("dx", quad.arg2, fp);
		if (strcmp(quad.quad, "+") == 0)
			fprintf(fp, "\tadd ax,dx\n");
		else
			fprintf(fp, "\tsub ax,dx\n");
		store("ax", quad.dest, fp);
	}
	else if (strcmp(quad.quad, "*") == 0){
		load("ax", quad.arg1, fp);
		load("cx", quad.arg2, fp);
		fprintf(fp, "\timul cx\n");
		store("ax", quad.dest, fp);
	}
	else if (strcmp(quad.quad, "/") == 0){
		load("ax", quad.arg1, fp);
		fprintf(fp, "\tcwd\n");
		load("cx", quad.arg2, fp);
		fprintf(fp, "\tidiv cx\n");
		store("ax", quad.dest, fp);
	}
	else if ((strcmp(quad.quad, "=") == 0) || (strcmp(quad.quad, "<>") == 0) || (strcmp(quad.quad, "<") == 0) || (strcmp(quad.quad, ">") == 0) || (strcmp(quad.quad, "<=") == 0) || (strcmp(quad.quad, ">=") == 0)){
		load("ax", quad.arg1, fp);
		load("dx", quad.arg2, fp);
		fprintf(fp, "\tcmp ax,dx\n");

		temp_label = label(quad.dest);

		if (strcmp(quad.quad, "=") == 0)
			fprintf(fp, "\tje %s\n", temp_label);
		if (strcmp(quad.quad, "<>") == 0)
			fprintf(fp, "\tjne %s\n", temp_label);
		if (strcmp(quad.quad, ">") == 0)
			fprintf(fp, "\tjg %s\n", temp_label);
		if (strcmp(quad.quad, "<") == 0)
			fprintf(fp, "\tjl %s\n", temp_label);
		if (strcmp(quad.quad, ">=") == 0)
			fprintf(fp, "\tjge %s\n", temp_label);
		if (strcmp(quad.quad, "<=") == 0)
			fprintf(fp, "\tjle %s\n", temp_label);
	}
	else if (strcmp(quad.quad, "unit") == 0){
		temp_name = name(quad.arg1);
		fprintf(fp, "%s proc near\n\tpush bp\n\tmov bp,sp\n\tsub sp,size\n", temp_name);
	}
	else if (strcmp(quad.quad, "endu") == 0){
		temp_name = name(quad.arg1);
		temp_endof = endof(quad.arg1);
		fprintf(fp, "%s: mov sp,bp\n\tpop bp\n\tret\n%s endp\n", temp_endof, temp_name);
	}
	else if (strcmp(quad.quad, "call") == 0){
		temp_name = name(quad.dest);
		fprintf(fp, "\tsub sp,2\n");
		updateAL(fp);
		fprintf(fp, "\tcall near ptr %s\n\tadd sp,size+4\n", temp_name);
	}
	else if (strcmp(quad.quad, "ret") == 0){
		temp_endof = endof("current");
		fprintf(fp, "\tjmp %s\n", temp_endof);
	}
	else if (strcmp(quad.quad, "jump") == 0){
		temp_label = label(quad.dest);
		fprintf(fp, "\tjmp %s\n", temp_label);
	}
	else if (strcmp(quad.quad, "par") == 0){
		if (strcmp(quad.arg2, "VALUE") == 0){
			load("ax", quad.arg1, fp);
			fprintf(fp, "\tpush ax\n");
		}
		else if (strcmp(quad.arg2, "VALUE") == 0){
			load("ax", quad.arg1, fp);
			fprintf(fp, "\tpush ax\n");
		}
		else if ((strcmp(quad.arg2, "REFFERENCE") == 0) || (strcmp(quad.arg2, "RET") == 0)){
			loadAddr("si", quad.arg1, fp);
			fprintf(fp, "\tpush si\n");
		}
	}
	else {
		fprintf(fp, "*** quad: %s not implemented yet***\n", quad.quad);
	}
}

void getAR(char * a, FILE * fp){
	fprintf(fp, "\tgetAR(%s)\n", a);
}

void load(char * a, char * b, FILE * fp){
	fprintf(fp, "\tload(%s,%s)\n", a, b);
}

void store(char * a, char * b, FILE * fp){
	fprintf(fp, "\tstore(%s,%s)\n", a, b);
}

void loadAddr(char * a, char * b, FILE * fp){
	fprintf(fp, "\tloadAddr(%s,%s)\n", a, b);
}

void updateAL(FILE * fp){
	fprintf(fp, "\tupdateAL()\n");
}

char * endof(char * a){
	char msg[256];
	char * endof;

	sprintf(msg, "endof(%s)", a);
	endof = strdup(msg);
	return endof;
}

char * label(char * a){
	char msg[256];
	char * label;

	sprintf(msg, "label(%s)", a);
	label = strdup(msg);
	return label;
}

char * name(char * a){
	char msg[256];
	char * name;

	sprintf(msg, "name(%s)", a);
	name = strdup(msg);
	return name;
}

void print_consumed_quad(Interpreted_quad quad){
	printf("%d: [%s, %s, %s, %s]\n", quad.id, quad.quad, quad.arg1, quad.arg2, quad.dest);
}
