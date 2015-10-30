#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "symbol.h"
#include "generator.h"
#include "quads.h"


void generator(){
	int i;
	char program[256];
	FILE * fp, * fp2;

	fp = fopen("code.txt", "w+");
	fp2 = fopen("quads.txt", "r");
	fscanf(fp2, "%[^\t\n]\n", program);
	fprintf(fp, "xseg segment public´code´\n\tassume cs:xseg, ds:xseg, ss:xseg\n\torg 100h\nmain proc near\n\tcall near ptr %s\n\tmov ax,4C00h\n\tint 21h\nmain endp\n", program);

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
	char quad[256], arg1[256], arg2[256], dest[256], nest[1];
	char arg1_pm[256], arg1_type[256], arg1_nesting[256], arg1_kind[256], arg1_offset[256];
	char arg2_pm[256], arg2_type[256], arg2_nesting[256], arg2_kind[256], arg2_offset[256];
	char dest_pm[256], dest_type[256], dest_nesting[256], dest_kind[256], dest_offset[256];
	Interpreted_quad interpreted_quad;

	fscanf(fp, "%d: %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n,], %[^\t\n]\n",
		&num, quad, arg1, arg2, dest, nest,
		arg1_pm, arg1_type, arg1_nesting, arg1_kind, arg1_offset,
		arg2_pm, arg2_type, arg2_nesting, arg2_kind, arg2_offset,
		dest_pm, dest_type, dest_nesting, dest_kind, dest_offset
		);

	interpreted_quad.id           = num;
	interpreted_quad.quad         = strdup(quad);
	interpreted_quad.arg1         = strdup(arg1);
	interpreted_quad.arg2         = strdup(arg2);
	interpreted_quad.dest         = strdup(dest);
	interpreted_quad.nesting      = strdup(nest);
	interpreted_quad.arg1_pm      = strdup(arg1_pm);
	interpreted_quad.arg1_type    = strdup(arg1_type);
	interpreted_quad.arg1_nesting = strdup(arg1_nesting);
	interpreted_quad.arg1_kind    = strdup(arg1_kind);
	interpreted_quad.arg1_offset  = strdup(arg1_offset);
	interpreted_quad.arg2_pm      = strdup(arg2_pm);
	interpreted_quad.arg2_type    = strdup(arg2_type);
	interpreted_quad.arg2_nesting = strdup(arg2_nesting);
	interpreted_quad.arg2_kind    = strdup(arg2_kind);
	interpreted_quad.arg2_offset  = strdup(arg2_offset);
	interpreted_quad.dest_pm      = strdup(dest_pm);
	interpreted_quad.dest_type    = strdup(dest_type);
	interpreted_quad.dest_nesting = strdup(dest_nesting);
	interpreted_quad.dest_kind    = strdup(dest_kind);
	interpreted_quad.dest_offset  = strdup(dest_offset);

	return interpreted_quad;
}


void generate(Interpreted_quad quad, FILE * fp){
	char * temp_label, * temp_name, * temp_endof;
	if (strcmp(quad.quad, ":=") == 0){
		if(strcmp(quad.arg1_kind, "integer") == 0){
			load("ax", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
			store("ax", quad.dest, fp, quad.dest_pm, quad.dest_type, quad.dest_nesting, quad.nesting, quad.dest_kind, quad.dest_offset);
		} else {
			load("al", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
			store("al", quad.dest, fp, quad.dest_pm, quad.dest_type, quad.dest_nesting, quad.nesting, quad.dest_kind, quad.dest_offset);
		}
	}
	else if ((strcmp(quad.quad, "+") == 0) || (strcmp(quad.quad, "-") == 0)){
		load("ax", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
		load("dx", quad.arg2, fp, quad.arg2_pm, quad.arg2_type, quad.arg2_nesting, quad.nesting, quad.arg2_kind, quad.arg2_offset);
		if (strcmp(quad.quad, "+") == 0)
			fprintf(fp, "\tadd ax,dx\n");
		else
			fprintf(fp, "\tsub ax,dx\n");
		store("ax", quad.dest, fp, quad.dest_pm, quad.dest_type, quad.dest_nesting, quad.nesting, quad.dest_kind, quad.dest_offset);
	}
	else if (strcmp(quad.quad, "*") == 0){
		load("ax", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
		load("cx", quad.arg2, fp, quad.arg2_pm, quad.arg2_type, quad.arg2_nesting, quad.nesting, quad.arg2_kind, quad.arg2_offset);
		fprintf(fp, "\timul cx\n");
		store("ax", quad.dest, fp, quad.dest_pm, quad.dest_type, quad.dest_nesting, quad.nesting, quad.dest_kind, quad.dest_offset);
	}
	else if (strcmp(quad.quad, "/") == 0){
		load("ax", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
		fprintf(fp, "\tcwd\n");
		load("cx", quad.arg2, fp, quad.arg2_pm, quad.arg2_type, quad.arg2_nesting, quad.nesting, quad.arg2_kind, quad.arg2_offset);
		fprintf(fp, "\tidiv cx\n");
		store("ax", quad.dest, fp, quad.dest_pm, quad.dest_type, quad.dest_nesting, quad.nesting, quad.dest_kind, quad.dest_offset);
	}
	else if ((strcmp(quad.quad, "=") == 0) || (strcmp(quad.quad, "<>") == 0) || (strcmp(quad.quad, "<") == 0) || (strcmp(quad.quad, ">") == 0) || (strcmp(quad.quad, "<=") == 0) || (strcmp(quad.quad, ">=") == 0)){
		load("ax", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
		load("dx", quad.arg2, fp, quad.arg2_pm, quad.arg2_type, quad.arg2_nesting, quad.nesting, quad.arg2_kind, quad.arg2_offset);
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
		updateAL(fp, quad.dest, quad.nesting);
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
			load("ax", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
			fprintf(fp, "\tpush ax\n");
		}
		else if (strcmp(quad.arg2, "VALUE") == 0){
			load("ax", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
			fprintf(fp, "\tpush ax\n");
		}
		else if ((strcmp(quad.arg2, "REFFERENCE") == 0) || (strcmp(quad.arg2, "RET") == 0)){
			loadAddr("si", quad.arg1, fp, quad.arg1_pm, quad.arg1_type, quad.arg1_nesting, quad.nesting, quad.arg1_kind, quad.arg1_offset);
			fprintf(fp, "\tpush si\n");
		}
	}
	else {
		fprintf(fp, "*** quad: %s not implemented yet***\n", quad.quad);
	}
}

void getAR(char * a, FILE * fp, char * nesting){
	int na, ncur, times, i;

	na = atoi(a);
	ncur = atoi(nesting);
	times = ncur - na - 1;
	fprintf(fp, "\tmov si, word ptr [bp+4]\n");
	for (i=0; i < times ; i++)
		fprintf(fp, "\tmov si, word ptr [bp+4]\n");
	/*printf("%d\n", times);
	fprintf(fp, "\tgetAR(%s)\n", a);*/
}

void load(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offset){

	if(isdigit(b[0]))
		fprintf(fp, "\tmov %s,%s\n", a, b);
	else if (strcmp(b, "true") == 0)
		fprintf(fp, "\tmov %s,1\n", a);
	else if ((strcmp(b, "false") == 0) || (strcmp(b, "nil") == 0 ))
		fprintf(fp, "\tmov %s,0\n", a);
	else if (b[0] == '\'')
		fprintf(fp, "\tmov %s,%d\n", a, (int) b[1]);
	else if(atoi(data_nesting)==atoi(nesting)) {
		if((strcmp(data_type, "variable") == 0) || (strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "value") == 0) || 
			(strcmp(data_type, "temporary") == 0))
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov %s, word ptr [bp + %d]\n", a, atoi(data_offset));
			else
				fprintf(fp, "\tmov %s, byte ptr [bp + %d]\n", a, atoi(data_offset));
		else if ((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "reference") == 0) ) {
			fprintf(fp, "\tmov si, word ptr [bp + %d]\n", atoi(data_offset));
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov %s, word ptr [si]\n", a);
			else
				fprintf(fp, "\tmov %s, byte ptr [si]\n", a);
		}
	} else
		if((strcmp(data_type, "variable") == 0) || (strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "value") == 0) || 
			(strcmp(data_type, "temporary") == 0)){
			getAR(data_nesting, fp, nesting);
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov %s, word ptr [si + %d]\n", a, atoi(data_offset));
			else
				fprintf(fp, "\tmov %s, byte ptr [si + %d]\n", a, atoi(data_offset));
		} else if ((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "reference") == 0) ) {
			getAR(data_nesting, fp, nesting);
			fprintf(fp, "\tmov si, word ptr [si + %d]\n", atoi(data_offset));
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov %s, word ptr [si]\n", a);
			else
				fprintf(fp, "\tmov %s, byte ptr [si]\n", a);
		}
}

void store(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offset){
	if(atoi(data_nesting)==atoi(nesting)) {
		if((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "value") == 0) || (strcmp(data_type, "temporary") == 0))
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov word ptr [bp + %d], %s\n", atoi(data_offset), a);
			else
				fprintf(fp, "\tmov byte ptr [bp + %d], %s\n", atoi(data_offset), a);
		else if ((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "reference") == 0) ) {
			fprintf(fp, "\tmov si, word ptr [bp + %d]\n", atoi(data_offset));
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov word ptr [si], %s\n", a);
			else
				fprintf(fp, "\tmov byte ptr [si], %s\n", a);
		}
	} else
		if((strcmp(data_type, "variable") == 0) || (strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "value") == 0) || 
			(strcmp(data_type, "temporary") == 0)){
			getAR(data_nesting, fp, nesting);
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov word ptr [si + %d], %s\n", atoi(data_offset), a);
			else
				fprintf(fp, "\tmov byte ptr [si + %d], %s\n", atoi(data_offset), a);
		} else if ((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "reference") == 0) ) {
			getAR(data_nesting, fp, nesting);
			fprintf(fp, "\tmov si, word ptr [si + %d]\n", atoi(data_offset));
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tmov word ptr [si], %s\n", a);
			else
				fprintf(fp, "\tmov byte ptr [si], %s\n", a);
		}
}

void loadAddr(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offset){
	if (b[0] == '\"')
		fprintf(fp, "\tlea %s,byte ptr %s\n", a, b);
	else if(atoi(data_nesting)==atoi(nesting)) {
		if((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "value") == 0) || (strcmp(data_type, "temporary") == 0))
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tlea %s, word ptr [bp + %d]\n", a, atoi(data_offset));
			else
				fprintf(fp, "\tlea %s, byte ptr [bp + %d]\n", a, atoi(data_offset));
		else if ((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "reference") == 0) ) {
			fprintf(fp, "\tmov %s, word ptr [bp + %d]\n", a, atoi(data_offset));
		}
	} else
		if((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "value") == 0) || (strcmp(data_type, "temporary") == 0)){
			getAR(data_nesting, fp, nesting);
			if(strcmp(data_kind, "integer") == 0)
				fprintf(fp, "\tlea %s, word ptr [si + %d]\n", a, atoi(data_offset));
			else
				fprintf(fp, "\tlea %s, byte ptr [si + %d]\n", a, atoi(data_offset));
		} else if ((strcmp(data_type, "parameter") == 0 && strcmp(data_pm, "reference") == 0) ) {
			getAR(data_nesting, fp, nesting);
			fprintf(fp, "\tmov %s, word ptr [si + %d]\n", a, atoi(data_offset));
		}
}

void updateAL(FILE * fp, char * a, char * nesting){
	/*fprintf(fp, "\tupdateAL()\n");*/
	int np, nx, times, i;

	nx = atoi(a);
	np = atoi(nesting);
	times = np - nx - 1;;

	if (np<nx)
		fprintf(fp, "\tpush bp\n");
	else if (np==nx)
		fprintf(fp, "\tpush word [bp+4]\n");
	else {
		fprintf(fp, "\tmov si, word [bp+4]\n");
		for (i=0; i < times ; i++)
			fprintf(fp, "\tmov si, word ptr [bp+4]\n");
		fprintf(fp, "\tpush word ptr [si+4]\n");
	}
}

char * endof(char * a){
	char msg[256];
	char * endof;

	sprintf(msg, "@%s_", a);
	endof = strdup(msg);
	return endof;
}

char * label(char * a){
	char msg[256];
	char * label;

	sprintf(msg, "@%s", a);
	label = strdup(msg);
	return label;
}

char * name(char * a){
	char msg[256];
	char * name;

	sprintf(msg, "_%s_", a);
	name = strdup(msg);
	return name;
}

void print_consumed_quad(Interpreted_quad quad){
	printf("%d: [%s, %s, %s, %s]\n", quad.id, quad.quad, quad.arg1, quad.arg2, quad.dest);
}
