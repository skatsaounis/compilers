#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "symbol.h"
#include "general.h"
#include "error.h"
#include "quads.h"

#include "parser.h"

long nextquad = 0;
Quad quad_array[MAX_QUAD_NUM];

char *strdup(const char *str)
{
    int n = strlen(str) + 1;
    char *dup = malloc(n);
    if(dup)
    {
        strcpy(dup, str);
    }
    return dup;
}

long GenQuad(QuadType q, SymbolEntry * x, SymbolEntry * y, SymbolEntry * z)
{
	quad_array[nextquad].type = q;
	if (x == NULL)
		quad_array[nextquad].arg1 = "-";
        else if (x->entryType == ENTRY_CONSTANT){
                char bufferx[1];
                switch (x->u.eConstant.type->kind) {
                    case TYPE_INTEGER:
                        sprintf(bufferx, "%d", (int) x->u.eConstant.value.vInteger);
                        break;
                    case TYPE_BOOLEAN:
                        sprintf(bufferx, "%u", (unsigned char) x->u.eConstant.value.vBoolean);
                        break;
                    case TYPE_CHAR:
                        sprintf(bufferx, "%s", (char *) x->u.eConstant.value.vString);
                        break;
                    case TYPE_IARRAY:
                        sprintf(bufferx, "%s", (char *) x->u.eConstant.value.vString);
                }
                quad_array[nextquad].arg1 = strdup(bufferx);
        }
        else
		quad_array[nextquad].arg1 = (char *) x->id;
	if (y == NULL)
		quad_array[nextquad].arg2 = "-";
	else if (y->entryType == ENTRY_CONSTANT){
                char buffery[1];
                switch (y->u.eConstant.type->kind) {
                    case TYPE_INTEGER:
                        sprintf(buffery, "%d", (int) y->u.eConstant.value.vInteger);
                        break;
                    case TYPE_BOOLEAN:
                        sprintf(buffery, "%u", (unsigned char) y->u.eConstant.value.vBoolean);
                        break;
                    case TYPE_CHAR:
                        sprintf(buffery, "%s", (char *) y->u.eConstant.value.vString);
                        break;
                    case TYPE_IARRAY:
                        sprintf(buffery, "%s", (char *) y->u.eConstant.value.vString);
                }
                quad_array[nextquad].arg2 = strdup(buffery);
        }
	else
		quad_array[nextquad].arg2 = (char *) y->id;
	if (z == NULL)
		quad_array[nextquad].dest = "-";
	else
		quad_array[nextquad].dest = (char *) z->id;
        /*printf("x: %s y: %s z: %s\n",quad_array[nextquad].arg1,quad_array[nextquad].arg2,quad_array[nextquad].dest);*/
	return nextquad++;
}

long GenQuad2(QuadType q, SymbolEntry * x, SymbolEntry * y, char * z)
{
	quad_array[nextquad].type=q;
	if (x == NULL)
		quad_array[nextquad].arg1 = "-";
        else if (x->entryType == ENTRY_CONSTANT){
                char bufferx[1];
                switch (x->u.eConstant.type->kind) {
                    case TYPE_INTEGER:
                        sprintf(bufferx, "%d", (int) x->u.eConstant.value.vInteger);
                        break;
                    case TYPE_BOOLEAN:
                        sprintf(bufferx, "%u", (unsigned char) x->u.eConstant.value.vBoolean);
                        break;
                    case TYPE_CHAR:
                        sprintf(bufferx, "%s", (char *) x->u.eConstant.value.vString);
                        break;
                    case TYPE_IARRAY:
                        sprintf(bufferx, "%s", (char *) x->u.eConstant.value.vString);
                }
                quad_array[nextquad].arg1 = strdup(bufferx);
        }
        else
		quad_array[nextquad].arg1 = (char *) x->id;
	if (y == NULL)
		quad_array[nextquad].arg2 = "-";
	else if (y->entryType == ENTRY_CONSTANT){
                char buffery[1];
                switch (y->u.eConstant.type->kind) {
                    case TYPE_INTEGER:
                        sprintf(buffery, "%d", (int) y->u.eConstant.value.vInteger);
                        break;
                    case TYPE_BOOLEAN:
                        sprintf(buffery, "%u", (unsigned char) y->u.eConstant.value.vBoolean);
                        break;
                    case TYPE_CHAR:
                        sprintf(buffery, "%s", (char *) y->u.eConstant.value.vString);
                        break;
                    case TYPE_IARRAY:
                        sprintf(buffery, "%s", (char *) y->u.eConstant.value.vString);
                }
                quad_array[nextquad].arg2 = strdup(buffery);
        }
	else
		quad_array[nextquad].arg2 = (char *) y->id;
	quad_array[nextquad].dest = strdup(z);
	/*printf("x: %s y: %s z: %s\n",quad_array[nextquad].arg1,quad_array[nextquad].arg2,quad_array[nextquad].dest);*/
        return nextquad++;
}

long GenQuad3(QuadType q, char * x, char * y, char * z)
{
	quad_array[nextquad].type = q;
	if (x == NULL)
		quad_array[nextquad].arg1 = "-";
	else
		quad_array[nextquad].arg1 = strdup(x);
	if (y == NULL)
		quad_array[nextquad].arg2 = "-";
	else
		quad_array[nextquad].arg2 = strdup(y);
	if (z == NULL)
		quad_array[nextquad].dest = "-";
	else
		quad_array[nextquad].dest = strdup(z);
	/*printf("x: %s y: %s z: %s\n",quad_array[nextquad].arg1,quad_array[nextquad].arg2,quad_array[nextquad].dest);*/
        return nextquad++;
}

long GenQuad4(QuadType q, SymbolEntry * x, char * y, char * z)
{
	quad_array[nextquad].type=q;
	if (x == NULL)
		quad_array[nextquad].arg1 = "-";
        else if (x->entryType == ENTRY_CONSTANT){
                char bufferx[1];
                switch (x->u.eConstant.type->kind) {
                    case TYPE_INTEGER:
                        sprintf(bufferx, "%d", (int) x->u.eConstant.value.vInteger);
                        break;
                    case TYPE_BOOLEAN:
                        sprintf(bufferx, "%u", (unsigned char) x->u.eConstant.value.vBoolean);
                        break;
                    case TYPE_CHAR:
                        sprintf(bufferx, "%s", (char *) x->u.eConstant.value.vString);
                        break;
                    case TYPE_IARRAY:
                        sprintf(bufferx, "%s", (char *) x->u.eConstant.value.vString);
                }
                quad_array[nextquad].arg1 = strdup(bufferx);
        }
        else
		quad_array[nextquad].arg1 = (char *) x->id;
	if (y == NULL)
		quad_array[nextquad].arg2 = "-";
	else
		quad_array[nextquad].arg2 = strdup(y);
	if (z == NULL)
		quad_array[nextquad].dest = "-";
	else
		quad_array[nextquad].dest = strdup(z);

	/*printf("x: %s y: %s z: %s\n",quad_array[nextquad].arg1,quad_array[nextquad].arg2,quad_array[nextquad].dest);*/
        return nextquad++;
}

label_list emptylist(){
	return NULL;
}

label_list make_list(long val)
{
	label_list l = (label_list) new(sizeof(label_list_t));
	l->label = val;
	l->next = NULL;
	return l;
}

label_list merge(label_list a, label_list b){
	if (b == NULL)
        return a;
    label_list l = a;
	if (l == NULL)
		return b;
	while (l->next != NULL)
		l = l->next;
	l->next = b;
	return a;
}

void backpatch(label_list list, long val){
	label_list l = list;
	char tmp[256];
	sprintf(tmp, "%d", val); /*the previous implementation was giving wrong result*/
	while ((list = l) != NULL) {
		delete(quad_array[l->label].dest);
		quad_array[l->label].dest = strdup(tmp);
		l = l->next;
		delete(list);
	}
}

char * print_quad(int i){
	char * s;
	switch(quad_array[i].type) {
			case PLUS_QUAD:		s="+"; break; /* 1 */
			case MINUS_QUAD:	s="-"; break;
			case MULT_QUAD:		s="*"; break;
			case DIV_QUAD:		s="/"; break;
			case MOD_QUAD:		s="%"; break; /* 5 */
			case JMP_QUAD:		s="jump"; break;
			case ASSIGN_QUAD:	s=":="; break;
			case EQ_QUAD:		s="="; break;
			case NE_QUAD:		s="<>"; break;
			case GT_QUAD:		s=">"; break; /* 10 */
			case LT_QUAD:		s="<"; break;
			case GE_QUAD:		s=">="; break;
			case LE_QUAD:		s="<=";	break;
			case UNIT_QUAD:		s="unit"; break;
			case ENDU_QUAD:		s="endu"; break; /* 15 */
			case PAR_QUAD:		s="par"; break;
			case CALL_QUAD:		s="call"; break;
			case RET_QUAD:		s="ret"; break;
                        case RETV_QUAD:		s="retv"; break;
                        case HEAD_QUAD:         s="head"; break;
                        case TAIL_QUAD:         s="tail"; break; /* 20 */
                        case ISNIL_QUAD:        s="nil?"; break;
                        case ARRAY_QUAD:        s="array"; break;
                        case LIST_QUAD:         s="list"; break;
			default:
				error("GenQuad: Internal Error\n");
		}
	return s;
}

char * outp(char * inp){
        if (inp == NULL)
                return "-";
        else
                return inp;
}

void print_all_quads(){
        static int i = 0;
        for(; i < nextquad; i++)
                printf("quad: %d [%s, %s, %s, %s]\n", i, print_quad(i), quad_array[i].arg1, quad_array[i].arg2, quad_array[i].dest);
}
