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
	char tmp[1];

    quad_array[nextquad].type = q;
    if (x == NULL)
	   quad_array[nextquad].arg1 = "-";
    else if (x->entryType == ENTRY_CONSTANT){
        char bufferx[256];
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

    quad_array[nextquad].arg1_req.type = symbol_type (x);
    quad_array[nextquad].arg1_req.pm = symbol_pm (x);
    quad_array[nextquad].arg1_req.kind = symbol_kind (x);
    quad_array[nextquad].arg1_req.offset = symbol_offset (x);
    if (x != NULL)
        sprintf(tmp, "%u", x->nestingLevel);
    else
        sprintf(tmp, "-");
    quad_array[nextquad].arg1_req.nesting = strdup(tmp);

    if (y == NULL)
		quad_array[nextquad].arg2 = "-";
    else if (y->entryType == ENTRY_CONSTANT){
                char buffery[256];
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

    quad_array[nextquad].arg2_req.type = symbol_type (y);
    quad_array[nextquad].arg2_req.pm = symbol_pm (y);
    quad_array[nextquad].arg2_req.kind = symbol_kind (y);
    quad_array[nextquad].arg2_req.offset = symbol_offset (y);
    if (y != NULL)
        sprintf(tmp, "%u", y->nestingLevel);
    else
        sprintf(tmp, "-");
    quad_array[nextquad].arg2_req.nesting = strdup(tmp);

	if (z == NULL)
		quad_array[nextquad].dest = "-";
	else
		quad_array[nextquad].dest = (char *) z->id;

    quad_array[nextquad].dest_req.type = symbol_type (z);
    quad_array[nextquad].dest_req.pm = symbol_pm (z);
    quad_array[nextquad].dest_req.kind = symbol_kind (z);
    quad_array[nextquad].dest_req.offset = symbol_offset (z);
    if (z != NULL)
        sprintf(tmp, "%u", z->nestingLevel);
    else
        sprintf(tmp, "-");
    quad_array[nextquad].dest_req.nesting = strdup(tmp);

    return nextquad++;
}

long GenQuad2(QuadType q, SymbolEntry * x, SymbolEntry * y, char * z)
{
    char tmp[1];

	quad_array[nextquad].type=q;
	if (x == NULL)
		quad_array[nextquad].arg1 = "-";
        else if (x->entryType == ENTRY_CONSTANT){
                char bufferx[256];
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

    quad_array[nextquad].arg1_req.type = symbol_type (x);
    quad_array[nextquad].arg1_req.pm = symbol_pm (x);
    quad_array[nextquad].arg1_req.kind = symbol_kind (x);
    quad_array[nextquad].arg1_req.offset = symbol_offset (x);
    if (x != NULL)
        sprintf(tmp, "%u", x->nestingLevel);
    else
        sprintf(tmp, "-");
    quad_array[nextquad].arg1_req.nesting = strdup(tmp);

	if (y == NULL)
		quad_array[nextquad].arg2 = "-";
	else if (y->entryType == ENTRY_CONSTANT){
                char buffery[256];
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

    quad_array[nextquad].arg2_req.type = symbol_type (y);
    quad_array[nextquad].arg2_req.pm = symbol_pm (y);
    quad_array[nextquad].arg2_req.kind = symbol_kind (y);
    quad_array[nextquad].arg2_req.offset = symbol_offset (y);
    if (y != NULL)
        sprintf(tmp, "%u", y->nestingLevel);
    else
        sprintf(tmp, "-");
    quad_array[nextquad].arg2_req.nesting = strdup(tmp);

	quad_array[nextquad].dest = strdup(z);

    quad_array[nextquad].dest_req.type = strdup("-");
    quad_array[nextquad].dest_req.pm = strdup("-");
    quad_array[nextquad].dest_req.nesting = strdup("-");
    quad_array[nextquad].dest_req.kind = strdup("-");
    quad_array[nextquad].dest_req.offset = strdup("-");
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

    quad_array[nextquad].arg1_req.type = strdup("-");
    quad_array[nextquad].arg1_req.pm = strdup("-");
    quad_array[nextquad].arg1_req.nesting = strdup("-");
    quad_array[nextquad].arg1_req.kind = strdup("-");
    quad_array[nextquad].arg1_req.offset = strdup("-");
	if (y == NULL)
		quad_array[nextquad].arg2 = "-";
	else
		quad_array[nextquad].arg2 = strdup(y);

    quad_array[nextquad].arg2_req.type = strdup("-");
    quad_array[nextquad].arg2_req.pm = strdup("-");
    quad_array[nextquad].arg2_req.nesting = strdup("-");
    quad_array[nextquad].arg2_req.kind = strdup("-");
    quad_array[nextquad].arg2_req.offset = strdup("-");
	if (z == NULL)
		quad_array[nextquad].dest = "-";
	else
		quad_array[nextquad].dest = strdup(z);

    quad_array[nextquad].dest_req.type = strdup("-");
    quad_array[nextquad].dest_req.pm = strdup("-");
    quad_array[nextquad].dest_req.nesting = strdup("-");
    quad_array[nextquad].dest_req.kind = strdup("-");
    quad_array[nextquad].dest_req.offset = strdup("-");
	/*printf("x: %s y: %s z: %s\n",quad_array[nextquad].arg1,quad_array[nextquad].arg2,quad_array[nextquad].dest);*/
        return nextquad++;
}

long GenQuad4(QuadType q, SymbolEntry * x, char * y, char * z)
{
    char tmp[1];

	quad_array[nextquad].type=q;
	if (x == NULL)
		quad_array[nextquad].arg1 = "-";
        else if (x->entryType == ENTRY_CONSTANT){
                char bufferx[256];
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

    quad_array[nextquad].arg1_req.type = symbol_type (x);
    quad_array[nextquad].arg1_req.pm = symbol_pm (x);
    quad_array[nextquad].arg1_req.kind = symbol_kind (x);
    quad_array[nextquad].arg1_req.offset = symbol_offset (x);
    if (x != NULL)
        sprintf(tmp, "%u", x->nestingLevel);
    else
        sprintf(tmp, "-");
    quad_array[nextquad].arg1_req.nesting = strdup(tmp);

	if (y == NULL)
		quad_array[nextquad].arg2 = "-";
	else
		quad_array[nextquad].arg2 = strdup(y);

    quad_array[nextquad].arg2_req.type = strdup("-");
    quad_array[nextquad].arg2_req.pm = strdup("-");
    quad_array[nextquad].arg2_req.nesting = strdup("-");
    quad_array[nextquad].arg2_req.kind = strdup("-");
    quad_array[nextquad].arg2_req.offset = strdup("-");
	if (z == NULL)
		quad_array[nextquad].dest = "-";
	else
		quad_array[nextquad].dest = strdup(z);

    quad_array[nextquad].dest_req.type = strdup("-");
    quad_array[nextquad].dest_req.pm = strdup("-");
    quad_array[nextquad].dest_req.nesting = strdup("-");
    quad_array[nextquad].dest_req.kind = strdup("-");
    quad_array[nextquad].dest_req.offset = strdup("-");
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
        if(strcmp(quad_array[l->label].dest, "-1") == 0){
    		delete(quad_array[l->label].dest);
    		quad_array[l->label].dest = strdup(tmp);
        }
		l = l->next;
	}
}

char * print_quad(int i){
	char * s;
	switch(quad_array[i].type) {
			case PLUS_QUAD:		s="+";       break; /* 1 */
			case MINUS_QUAD:	s="-";       break;
			case MULT_QUAD:		s="*";       break;
			case DIV_QUAD:		s="/";       break;
			case MOD_QUAD:		s="%";       break; /* 5 */
			case JMP_QUAD:		s="jump";    break;
			case ASSIGN_QUAD:	s=":=";      break;
			case EQ_QUAD:		s="=";       break;
			case NE_QUAD:		s="<>";      break;
			case GT_QUAD:		s=">";       break; /* 10 */
			case LT_QUAD:		s="<";       break;
			case GE_QUAD:		s=">=";      break;
			case LE_QUAD:		s="<=";	     break;
			case UNIT_QUAD:		s="unit";    break;
			case ENDU_QUAD:		s="endu";    break; /* 15 */
			case PAR_QUAD:		s="par";     break;
			case CALL_QUAD:		s="call";    break;
			case RET_QUAD:		s="ret";     break;
            case RETV_QUAD:		s="retv";    break;
            case HEAD_QUAD:     s="head";    break;
            case TAIL_QUAD:     s="tail";    break; /* 20 */
            case ISNIL_QUAD:    s="nil?";    break;
            case ARRAY_QUAD:    s="array";   break;
            case LIST_QUAD:     s="list";    break;
            case PTR_QUAD:      s="pointer"; break;
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

void print_all_quads(FILE * fp){
        static int i = 0;
        for(; i < nextquad; i++)
            fprintf(fp, "%d: %s, %s, %s, %s, %u, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n", i, print_quad(i),
                quad_array[i].arg1, quad_array[i].arg2, quad_array[i].dest,
                currentScope->nestingLevel,
                quad_array[i].arg1_req.pm, quad_array[i].arg1_req.type, quad_array[i].arg1_req.nesting, 
		quad_array[i].arg1_req.kind, quad_array[i].arg1_req.offset,
                quad_array[i].arg2_req.pm, quad_array[i].arg2_req.type, quad_array[i].arg2_req.nesting, 
		quad_array[i].arg2_req.kind, quad_array[i].arg2_req.offset,
                quad_array[i].dest_req.pm, quad_array[i].dest_req.type, quad_array[i].dest_req.nesting, 
		quad_array[i].dest_req.kind, quad_array[i].dest_req.offset
                );
}


char * symbol_type (SymbolEntry * p){
    if (p == NULL)
        return strdup("-");
    switch(p->entryType){
        case ENTRY_CONSTANT:
            return strdup("constant");
            break;
        case ENTRY_FUNCTION:
            return strdup("function");
            break;
        case ENTRY_PARAMETER:
            return strdup("parameter");
            break;
        case ENTRY_VARIABLE:
            return strdup("variable");
            break;
        case ENTRY_TEMPORARY:
            return strdup("temporary");
            break;
    }
    return NULL;
}

char * symbol_pm (SymbolEntry * p){
    if (p == NULL)
        return strdup("-");
    switch(p->entryType){
        case ENTRY_PARAMETER:
            switch(p->u.eParameter.mode){
                case PASS_BY_VALUE:
                    return strdup("value");
                    break;
                case PASS_BY_REFERENCE:
                    return strdup("reference");
                    break;
                default:
                    break;
            }
            break;
        default:
            return strdup("-");
            break;
    }
    return NULL;
}

char * symbol_kind (SymbolEntry * p){
    if (p == NULL)
        return strdup("-");
    switch(p->entryType){
        case ENTRY_CONSTANT:
		switch (p->u.eConstant.type->kind) {
                    case TYPE_INTEGER:
                        return strdup("integer");
                        break;
                    case TYPE_BOOLEAN:
                        return strdup("boolean");
                        break;
                    case TYPE_CHAR:
                        return strdup("char");
                        break;
                    case TYPE_IARRAY:
                        return strdup("iarray");
			break;
                }	
            	break;
        case ENTRY_PARAMETER:
        	switch (p->u.eParameter.type->kind) {
                    case TYPE_INTEGER:
                        return strdup("integer");
                        break;
                    case TYPE_BOOLEAN:
                        return strdup("boolean");
                        break;
                    case TYPE_CHAR:
                        return strdup("char");
                        break;
                    case TYPE_IARRAY:
                        return strdup("iarray");
			break;
                }	
            	break;
        case ENTRY_VARIABLE:
            	switch (p->u.eVariable.type->kind) {
                    case TYPE_INTEGER:
                        return strdup("integer");
                        break;
                    case TYPE_BOOLEAN:
                        return strdup("boolean");
                        break;
                    case TYPE_CHAR:
                        return strdup("char");
                        break;
                    case TYPE_IARRAY:
                        return strdup("iarray");
			break;
                }	
            	break;
        case ENTRY_TEMPORARY:
            	switch (p->u.eTemporary.type->kind) {
                    case TYPE_INTEGER:
                        return strdup("integer");
                        break;
                    case TYPE_BOOLEAN:
                        return strdup("boolean");
                        break;
                    case TYPE_CHAR:
                        return strdup("char");
                        break;
                    case TYPE_IARRAY:
                        return strdup("iarray");
			break;
                }	
            	break;
    }
    return NULL;
}

char * symbol_offset (SymbolEntry * p){
    char buffer[256] ;
    if (p == NULL)
        return strdup("-");
    switch(p->entryType){
        case ENTRY_PARAMETER:
        	sprintf(buffer, "%d", (int) p->u.eParameter.offset);	
            	break;
        case ENTRY_VARIABLE:
            	sprintf(buffer, "%d", (int) p->u.eVariable.offset);	
            	break;
        case ENTRY_TEMPORARY:
            	sprintf(buffer, "%d", (int) p->u.eTemporary.offset);	
            	break;
	default:
		return strdup("-");
    }
    return strdup(buffer);
}
