#ifndef __GENERATOR_H__
#define __GENERATOR_H__

typedef struct{
	int id;
	char * quad;
	char * arg1;
	char * arg2;
	char * dest;
	char * nesting;
	char * arg1_pm, * arg1_type, * arg1_nesting, * arg1_kind, * arg1_offset, * arg1_prev_param_string;
	char * arg2_pm, * arg2_type, * arg2_nesting, * arg2_kind, * arg2_offset, * arg2_prev_param_string;
	char * dest_pm, * dest_type, * dest_nesting, * dest_kind, * dest_offset, * dest_prev_param_string;
	char * next_words;
}Interpreted_quad;

typedef struct program_strings_struct{
	int id;
	char * node_str;
	struct program_strings_struct * next;
}program_string_t;

typedef program_string_t * Program_strings;

void generator(int * externs, int * offsets);
Interpreted_quad consume_quad(FILE * fp);
void print_consumed_quad(Interpreted_quad quad);
void generate(Interpreted_quad quad, FILE * fp, int offset);
void load(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offet);
void store(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offset);
void loadAddr(char * a, char * b, FILE * fp, char * data_pm, char * data_type, char * data_nesting, char * nesting, char * data_kind, char * data_offset);
void updateAL(FILE * fp, char * a, char * nesting);
void getAR(char * a, FILE * fp, char * nesting);
char * endof(char * a);
char * label(char * a);
char * name(char * a);
void printstrings(FILE * fp);
void printexterns(FILE * fp, int * externs);
void printexterns2(FILE * fp, int * externs);
void string_to_db(FILE * fp, char * node_str);
void print_call_table(FILE * fp, char * fun_name, int call_counter, int temp_var_offset, int * param_byte_table, int * inception_function_table, char * next_words, char ** prev_param_offset_table);

#endif
