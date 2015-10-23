#ifndef __GENERATOR_H__
#define __GENERATOR_H__

typedef struct{
	int id;
	char * quad;
	char * arg1;
	char * arg2;
	char * dest;
}Interpreted_quad;

void generator(void);
Interpreted_quad consume_quad(FILE * fp);
void print_consumed_quad(Interpreted_quad quad);
void generate(Interpreted_quad quad, FILE * fp);
void load(char * a, char * b, FILE * fp);
void store(char * a, char * b, FILE * fp);
void loadAddr(char * a, char * b, FILE * fp);
void updateAL(FILE * fp);
char * endof(char * a);
char * label(char * a);
char * name(char * a);

#endif
