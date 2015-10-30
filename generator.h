#ifndef __GENERATOR_H__
#define __GENERATOR_H__

typedef struct{
	int id;
	char * quad;
	char * arg1;
	char * arg2;
	char * dest;
	char * nesting;
	char * arg1_pm, * arg1_type, * arg1_nesting, * arg1_kind, * arg1_offset;
	char * arg2_pm, * arg2_type, * arg2_nesting, * arg2_kind, * arg2_offset;
	char * dest_pm, * dest_type, * dest_nesting, * dest_kind, * dest_offset;
}Interpreted_quad;

void generator(void);
Interpreted_quad consume_quad(FILE * fp);
void print_consumed_quad(Interpreted_quad quad);
void generate(Interpreted_quad quad, FILE * fp);
void load(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offet);
void store(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offset);
void loadAddr(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offset);
void updateAL(FILE * fp, char * a, char * nesting);
void getAR(char * a, FILE * fp, char * nesting);
char * endof(char * a);
char * label(char * a);
char * name(char * a);

#endif
