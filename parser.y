%{
extern int yylex();
%}

%{
#include <stdarg.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>

#include "quads.h"
#include "error.h"
#include "symbol.h"
#include "general.h"
#include "generator.h"

typedef struct node node;
typedef struct if_temps if_temps;
typedef struct for_temps for_temps;
typedef struct prev_params prev_params;

struct node {
    SymbolEntry * a;
    SymbolEntry * b;
    node * prev;
};

struct if_temps {
    label_list temp1, temp2, temp3, temp4, temp5, temp6, temp7;
    if_temps * prev;
};

struct for_temps {
    char temp1[256];
    long temp2;
    char temp3[256];
    for_temps * prev;
};

struct prev_params {
    char * prev_param_string;
    prev_params * prev;
};

extern FILE *yyin;
int new_const;
int unit_counter, offset;
char units[256][256];
char unit_flags[256];
char buf[256];

FILE * fp1, *imm_stream, *final_stream;

if_temps * curr_if_temp, *if_temp;
for_temps * curr_for_temp, *for_temp;
prev_params * curr_param_node, *temp_param_node;

node * currnode, * temp;
int flag, ProduceFinal, ProduceInterm, main_flag = 0, counter = 0, logical_expr = 0;
int externs[21], offsets[257];
SymbolEntry * p, * W, * S;
Type type, refType;
PassMode pMode, pm;

void ERROR (const char * fmt, ...);

int custom_sizeof (Type refT) {
    switch (refT->kind) {
        case TYPE_INTEGER:
            return 2;
            break;
        case TYPE_BOOLEAN:
            return 1;
            break;
        case TYPE_CHAR:
            return 1;
            break;
        case TYPE_IARRAY:
            return 1; /* size in words (2 bytes) cause newarrp needs the size in words */
            break;
        case TYPE_LIST:
            return 1; /* size in words (2 bytes) cause newarrp needs the size in words */
            break;
        default:
            internal("Invalid type for refT");
            return -1;
    }
    /* never goes here */
    return 0;
}

void init_if_temps (if_temps * temps) {
    temps->temp1 = NULL;
    temps->temp2 = NULL;
    temps->temp3 = NULL;
    temps->temp4 = NULL;
    temps->temp5 = NULL;
    temps->temp6 = NULL;
    temps->temp7 = NULL;
}

void init_for_temps (for_temps * temps) {
    sprintf(temps->temp1, "-1");
    temps->temp2 = 0;
    sprintf(temps->temp3, "-1");
}


Type lookup_type_find (SymbolEntry * p) {
    Type value;
    if (p == NULL)
        ERROR("I am here\n");
    switch (p->entryType) {
        case ENTRY_CONSTANT:
            value = p->u.eConstant.type;
            break;
        case ENTRY_FUNCTION:
            value = p->u.eFunction.resultType;
            break;
        case ENTRY_PARAMETER:
            value = p->u.eParameter.type;
            break;
        case ENTRY_VARIABLE:
            value = p->u.eVariable.type;
            break;
        case ENTRY_TEMPORARY:
            value = p->u.eTemporary.type;
            break;
    }
    return value;
}

int cons_check (Type a, Type b) {
    if (a->kind == TYPE_LIST) {
        if (b->refType->kind == TYPE_LIST) {
            return cons_check(a->refType, b->refType);
        } else if (b->refType->refType->kind == TYPE_LIST) {
            return cons_check(a->refType, b->refType->refType);
        } else {
            return 0;
        }
    } else if (b->kind == TYPE_POINTER) {
        if (b->refType->refType->kind == TYPE_LIST) {
            return cons_check(a, b->refType->refType);
        } else {
            return 0; 
        }
    } else if (a->kind == TYPE_POINTER) {
        return cons_check(a->refType->refType,b);
    } else if (b->refType->kind != a->kind) {
        return 0;
    }
    return 1;
}

int assign_check (Type a, Type b) {
    if (a->kind == b->kind) {
        if (a->kind != TYPE_LIST) {
            return 1;
        }
        else {
            return assign_check(a->refType, b->refType);
        }
    }
    if (b->kind == TYPE_VOID) {
        return 1;
    }
    return 0;
}

Type lookup_type_in_arrays (Type p) {
    while (p->kind == TYPE_IARRAY || p->kind == TYPE_POINTER)
        p = p->refType;
    return p;
}

Type lookup_in_curScope () {
    return p->u.eFunction.resultType;
}

void ERROR (const char * fmt, ...);

void checkParams (SymbolEntry ** p, Type t) {
    if (*p == NULL)
        ERROR("More arguments than expected");
    else if (!equalType(lookup_type_find(*p),t))
        if ((t->kind == TYPE_IARRAY || t->kind == TYPE_POINTER) && equalType(lookup_type_find(*p),t->refType))
            *p = (*p)->u.eParameter.next;
        else
            ERROR("Typical and real parameters type mismatch");
    else
        *p = (*p)->u.eParameter.next;
}

void checkNoParams (SymbolEntry *p) {
    if (p != NULL)
        ERROR("Less arguments than expected");
}

void yyerror (const char *msg);

%}

%locations

%union {
    struct {
        int pointer;
        PassMode pm;
        Type refT;
        label_list true_list;
        label_list false_list;
        label_list next_list;
        int arithmetic;
        SymbolEntry * symbol_entry;
    } a;
    int n; /* used for T_num */
    char * s;
    char c; /* used for T_const */
}

%token T_and      "and"
%token T_bool     "bool"
%token T_char     "char"
%token T_decl     "decl"
%token T_def      "def"
%token T_else     "else"
%token T_elsif    "elsif"
%token T_end      "end"
%token T_exit     "exit"
%token T_false    "false"
%token T_for      "for"
%token T_head     "head"
%token T_if       "if"
%token T_int      "int"
%token T_list     "list"
%token T_mod      "mod"
%token T_new      "new"
%token T_nil      "nil"
%token T_nilq     "nil?"
%token T_not      "not"
%token T_or       "or"
%token T_ref      "ref"
%token T_return   "return"
%token T_skip     "skip"
%token T_tail     "tail"
%token T_true     "true"
%token<s> T_num
%token T_nequal   "<>"
%token T_gequal   ">="
%token T_lequal   "<="
%token T_assignor ":="
%token<s> T_id
%token<s> T_const
%token<s> T_string

%left "or"
%left "and"
%left "not"
%nonassoc '=' "<>" '>' '<' "<=" ">="
%right '#'
%left '+' '-'
%left '*' '/' "mod"
%left UMINUS UPLUS

%type<a> simple_list opt4 type opt1 opt3 expr atom call stmt stmt_list elsif_list else_list simple opt5 opt6


%%

program:
    {
        initSymbolTable(257);
        openScope(NULL);
        p = predefines();
    }
    func_def
    {
        closeScope();
    }
;

func_def:
    { flag = 0; }
    "def" header  ':' func_def_list
    {
        currentScope->unit_counter = unit_counter;
        sprintf(units[unit_counter++], "%s", currentScope->name);
        GenQuad3(UNIT_QUAD, currentScope->name, NULL, NULL);
        curr_param_node = NULL;
    }
    stmt_list "end"
    {
        GenQuad3(ENDU_QUAD, currentScope->name, NULL, NULL);
        offsets[counter] = -(currentScope->negOffset);
        counter++;
        print_all_quads(fp1, imm_stream);
        closeScope();
    }
;

func_def_list:
    /* nothing */
    | func_def func_def_list
    | func_decl func_def_list
    | var_def func_def_list
;

stmt_list: 
    stmt             { $$.next_list = $1.next_list;
                       $$.false_list = $1.false_list;
                       $$.true_list = $1.true_list;
                     }
    | stmt stmt_list { $$.next_list = $2.next_list;
                       $$.false_list = $2.false_list;
                       $$.true_list = $2.true_list;
                     }
;

header:
    opt1 T_id
    {   
        if (main_flag == 0) {
            main_flag = 1;
            fprintf(fp1, "%s\n", $2);
        }
        p = newFunction($2);
        if (flag) {
            forwardFunction(p);
        }
        openScope($2);
    }
    '(' opt2 ')'
    {
        endFunctionHeader(p, $1.refT);
    }
;

opt1:
    /* nothing */                   { $$.refT = typeVoid;            }
    | type                          { $$.refT = $1.refT;             }
;

opt2:
    /* nothing */
    | formal opt2_list
;

opt2_list:
    /* nothing */
    | ';' formal opt2_list
;

formal:
    opt3 type T_id
    {   
        if ($2.refT->kind == TYPE_IARRAY) {
            newParameter($3, $2.refT, PASS_BY_REFERENCE, p);
            type = $2.refT;
            pMode = PASS_BY_REFERENCE;
        } else {
            newParameter($3, $2.refT, $1.pm, p);
            type = $2.refT;
            pMode = $1.pm;
        }
    }
    formal_list
;

opt3:
                                    { $$.pm = PASS_BY_VALUE;       }
    | "ref"                         { $$.pm = PASS_BY_REFERENCE;   }
;

formal_list:
    /* nothing */
    | ',' T_id
    {  
        newParameter($2, type, pMode, p);
    }
    formal_list
;

type:
      "int"                         { $$.refT = typeInteger;         }
    | "bool"                        { $$.refT = typeBoolean;         }
    | "char"                        { $$.refT = typeChar;            }
    | type '[' ']'                  { $$.refT = typeIArray($1.refT); }
    | "list" '[' type ']'           { $$.refT = typeList($3.refT);   }
;

func_decl:
    { flag = 1; }
    "decl" header
    {
        closeScope();
    }
;

var_def:
    type T_id
    {   
        newVariable($2, $1.refT);
        type = $1.refT;
    }
    var_def_list
;

var_def_list:
    /* nothing */
    | ',' T_id
    {   
        newVariable($2, type);
    }
    var_def_list
;

stmt:
    simple              {
                            $$.next_list = $1.next_list;
                            $$.true_list = $1.true_list;
                            $$.false_list = $1.false_list;
                        }
    | "exit"            { $$.next_list = emptylist();  }
    | "return" expr     { 
                            if (!equalType(lookup_type_find($2.symbol_entry), lookup_in_curScope()))
                                ERROR("Wrong type for return value");
                            if ((($2.symbol_entry->entryType == ENTRY_CONSTANT) && ($2.symbol_entry->u.eConstant.type->kind == TYPE_BOOLEAN)) || (($2.symbol_entry->entryType == ENTRY_VARIABLE) && ($2.symbol_entry->u.eVariable.type->kind == TYPE_BOOLEAN)) || (($2.symbol_entry->entryType == ENTRY_TEMPORARY) && ($2.symbol_entry->u.eTemporary.type->kind == TYPE_BOOLEAN)))
                            {
                                backpatch($2.true_list,nextquad);
                                backpatch($2.false_list,nextquad);
                            }                          
                            GenQuad(RETV_QUAD, $2.symbol_entry, NULL, NULL, 0,"");
                            GenQuad(RET_QUAD, NULL, NULL, NULL, 0,"");
                        }
    | "if"              { logical_expr = 1; }
       expr             { 
                            if (lookup_type_find($3.symbol_entry) != typeBoolean)
                                ERROR("if exprs must be of type bool");
                            logical_expr = 0;
                            if_temp = (if_temps *) new(sizeof(if_temps));
                            init_if_temps(if_temp);
                            if_temp->prev = curr_if_temp;
                            curr_if_temp = if_temp;

                            backpatch($3.true_list, nextquad);
                            curr_if_temp->temp1 = $3.false_list;
                            curr_if_temp->temp4 = $3.false_list;
                            curr_if_temp->temp2 = emptylist();
                        }
      ':' stmt_list elsif_list else_list "end"
                        {
                            curr_if_temp->temp3 = merge(curr_if_temp->temp1, $6.next_list);
                            $$.next_list = merge(curr_if_temp->temp3, curr_if_temp->temp2);
                            backpatch(curr_if_temp->temp5, nextquad);
                            if_temp = curr_if_temp;
                            curr_if_temp = curr_if_temp->prev;
                            delete(if_temp);
                        }
    | "for" simple_list ';'
                        {
                            for_temp = (for_temps *) new(sizeof(for_temps));
                            init_for_temps(for_temp);
                            for_temp->prev = curr_for_temp;
                            curr_for_temp = for_temp;
                            sprintf(curr_for_temp->temp1, "%ld", nextquad);
                            logical_expr = 1;
                        }
      expr ';'          {
                            logical_expr = 0;
                            curr_for_temp->temp2 = nextquad;
                            sprintf(curr_for_temp->temp3, "%ld", nextquad);
                        }
      simple_list ':'   {
                            if (lookup_type_find($5.symbol_entry) != typeBoolean)
                                ERROR("for exprs must be of type bool");
                            GenQuad2(JMP_QUAD, NULL, NULL,curr_for_temp->temp1, 0,"");
                            backpatch($5.true_list,nextquad);
                        }
      stmt_list "end"   {
                            backpatch($11.next_list,curr_for_temp->temp2);
                            GenQuad2(JMP_QUAD, NULL, NULL,curr_for_temp->temp3, 0,"");
                            backpatch($5.false_list,nextquad);
                            $$.next_list = $5.false_list;
                            for_temp = curr_for_temp;
                            curr_for_temp = curr_for_temp->prev;
                            delete(for_temp);
                        }
;

elsif_list:
    /* nothing */       {
                          $$.next_list = emptylist();
                        }
    | "elsif"           { 
                            curr_if_temp->temp5 = merge(curr_if_temp->temp5, make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,"")));
                            backpatch(curr_if_temp->temp4, nextquad);
                            logical_expr = 1;
                        }
      expr              { 
                            if (lookup_type_find($3.symbol_entry) != typeBoolean)
                                ERROR("elsif exprs must be of type bool");
                            logical_expr = 0;
                            backpatch($3.true_list, nextquad);
                            curr_if_temp->temp4 = $3.false_list;
                            curr_if_temp->temp2 = emptylist();
                        }
      ':' stmt_list     {
                            curr_if_temp->temp2 = $6.next_list;
                        }
      elsif_list        {
                            $$.next_list = emptylist();
                        }
;

else_list:
    /* nothing */       {
                            backpatch(curr_if_temp->temp4,nextquad);
                            $$.next_list = emptylist();
                        }
    | "else"            {
                            curr_if_temp->temp1 = make_list(nextquad);
                            curr_if_temp->temp5 = merge(curr_if_temp->temp5, make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,"")));
                            backpatch(curr_if_temp->temp4, nextquad);
                        }
      ':' stmt_list     {
                            curr_if_temp->temp2 = $4.next_list;
                        }
;

simple:
    "skip"              { $$.next_list = emptylist(); }
    | atom ":=" expr    {
                            if (!equalType(lookup_type_in_arrays(lookup_type_find($1.symbol_entry)), lookup_type_in_arrays(lookup_type_find($3.symbol_entry))))
                                ERROR("not the same type of exprs");
                            if (lookup_type_find($1.symbol_entry)->kind == TYPE_LIST) {
                                if (assign_check(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)) == 0) {
                                    ERROR("not the same type of exprs");
                                }
                            }

                            if ((($3.symbol_entry->entryType == ENTRY_CONSTANT) && ($3.symbol_entry->u.eConstant.type->kind == TYPE_BOOLEAN)) || (($3.symbol_entry->entryType == ENTRY_VARIABLE) && ($3.symbol_entry->u.eVariable.type->kind == TYPE_BOOLEAN)) || (($3.symbol_entry->entryType == ENTRY_TEMPORARY) && ($3.symbol_entry->u.eTemporary.type->kind == TYPE_BOOLEAN)))
                            {
                                backpatch($3.true_list,nextquad);
                                backpatch($3.false_list,nextquad);
                            }
                            if ($3.pointer == 1) {
                                GenQuad4(PAR_QUAD, $3.symbol_entry, "RET", NULL);
                                GenQuad2(CALL_QUAD, NULL, NULL, "newarrv", 2,"");
                                externs[19] = 1;
                            } else if ($3.pointer == 2) {
                                GenQuad4(PAR_QUAD, $3.symbol_entry, "RET", NULL);
                                GenQuad2(CALL_QUAD, NULL, NULL, "newarrp", 2,"");
                                externs[18] = 1;
                            }
                            if ($3.arithmetic != 1) {
                                $$.next_list = make_list(GenQuad(ASSIGN_QUAD, $3.symbol_entry, NULL, $1.symbol_entry, 0,""));
                            }
                            else {
                                $$.next_list = make_list(dest_replace($1.symbol_entry));
                            }
                            $$.false_list = emptylist();
                            $$.true_list = emptylist();
                        }
    | call              { $$.next_list = emptylist(); }
;

simple_list: 
    simple opt4         { $$.next_list = $2.next_list; }
;

opt4: 
    /* nothing */       { $$.next_list = emptylist();  }
    | ',' simple opt4   { $$.next_list = $3.next_list; }
;

call:
    T_id                {
                            temp = (node *) new(sizeof(node));
                            temp->prev = currnode;
                            currnode = temp;
                            currnode->b = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
                            currnode->a = currnode->b->u.eFunction.firstArgument;

                            if (strcmp($1, "puti") == 0)
                                externs[0] = 1;
                            else if (strcmp($1, "putb") == 0 )
                                externs[1] = 1;
                            else if (strcmp($1, "putc") == 0)
                                externs[2] = 1;
                            else if (strcmp($1, "puts") == 0)
                                externs[3] = 1;
                            else if (strcmp($1, "geti") == 0)
                                externs[4] = 1;
                            else if (strcmp($1, "getb") == 0)
                                externs[5] = 1;
                            else if (strcmp($1, "getc") == 0)
                                externs[6] = 1;
                            else if (strcmp($1, "gets") == 0)
                                externs[7] = 1;
                            else if (strcmp($1, "abs") == 0)
                                externs[8] = 1;
                            else if (strcmp($1, "org") == 0)
                                externs[9] = 1;
                            else if (strcmp($1, "chr") == 0)
                                externs[10] = 1;
                            else if (strcmp($1, "strlen") == 0)
                                externs[11] = 1;
                            else if (strcmp($1, "strcmp") == 0)
                                externs[12] = 1;
                            else if (strcmp($1, "strcpy") == 0)
                                externs[13] = 1;
                            else if (strcmp($1, "strcat") == 0)
                                externs[14] = 1;
                        }
    '('                 {
                            temp_param_node = (prev_params *) new(sizeof(prev_params));
                            if (curr_param_node == NULL) {
                                temp_param_node->prev_param_string = strdup("");
                                temp_param_node->prev = NULL;
                            } else {
                                temp_param_node->prev_param_string = strdup(curr_param_node->prev_param_string);
                                temp_param_node->prev = curr_param_node;
                            }
                            curr_param_node = temp_param_node;
                        }
        opt5 ')'        {
                          $$.symbol_entry = $5.symbol_entry;
                          temp = currnode;
                          currnode = currnode->prev;
                          delete(temp);
                          temp_param_node = curr_param_node;
                          curr_param_node = curr_param_node->prev;
                          delete(temp_param_node);
                        }
;

opt5:
    /* nothing */       {
                            checkNoParams(currnode->a);
                            if (currnode->b->u.eFunction.resultType != typeVoid) {
                                $$.symbol_entry = newTemporary(currnode->b->u.eFunction.resultType);
                                GenQuad4(PAR_QUAD, $$.symbol_entry, "RET", NULL);
                            }
                            else
                                $$.symbol_entry = currnode->b;
                            currentScope->unit_flag = 1;
                            if (curr_param_node == NULL || curr_param_node->prev == NULL)
                                GenQuad(CALL_QUAD, NULL, NULL, currnode->b, 0, "");
                            else
                                GenQuad(CALL_QUAD, NULL, NULL, currnode->b, 0, curr_param_node->prev->prev_param_string);
                        }
    | expr              {
                            pm = currnode->a->u.eParameter.mode;
                            checkParams(&(currnode->a), lookup_type_find($1.symbol_entry));                          
                            if ((($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($1.symbol_entry->u.eConstant.type->kind == TYPE_BOOLEAN)) || (($1.symbol_entry->entryType == ENTRY_VARIABLE) && ($1.symbol_entry->u.eVariable.type->kind == TYPE_BOOLEAN)) || (($1.symbol_entry->entryType == ENTRY_TEMPORARY) && ($1.symbol_entry->u.eTemporary.type->kind == TYPE_BOOLEAN)))
                            {
                                backpatch($1.true_list,nextquad);
                                backpatch($1.false_list,nextquad);
                            }
                            if (pm == PASS_BY_VALUE)
                                GenQuad4(PAR_QUAD, $1.symbol_entry, "VALUE", NULL);
                            else
                                GenQuad4(PAR_QUAD, $1.symbol_entry, "REFERENCE", NULL);

                            switch ($1.symbol_entry->entryType) {
                                case ENTRY_CONSTANT:
                                case ENTRY_FUNCTION:
                                    break;
                                case ENTRY_PARAMETER:
                                    offset = $1.symbol_entry->u.eParameter.offset;
                                    break;
                                case ENTRY_VARIABLE:
                                    offset = $1.symbol_entry->u.eVariable.offset;
                                    break;
                                case ENTRY_TEMPORARY:
                                    offset = $1.symbol_entry->u.eTemporary.offset;
                                    break;
                            }
                            sprintf(buf, "dw %d\b", offset);
                            strcat(curr_param_node->prev_param_string, buf);
                        }
          opt6          { $$.symbol_entry = $3.symbol_entry; }
;

opt6:
    /* nothing */       {
                            checkNoParams(currnode->a);
                            if (currnode->b->u.eFunction.resultType != typeVoid) {
                                $$.symbol_entry = newTemporary(currnode->b->u.eFunction.resultType);
                                GenQuad4(PAR_QUAD, $$.symbol_entry, "RET", NULL);
                            }
                            else
                                $$.symbol_entry = currnode->b;
                            currentScope->unit_flag = 1;
                            if (curr_param_node == NULL || curr_param_node->prev == NULL)
                                GenQuad(CALL_QUAD, NULL, NULL, currnode->b, (currnode->b->u.eFunction.firstArgument)->u.eParameter.offset - 6, "");
                            else
                                GenQuad(CALL_QUAD, NULL, NULL, currnode->b, (currnode->b->u.eFunction.firstArgument)->u.eParameter.offset - 6, curr_param_node->prev->prev_param_string);
                        }
    | ',' expr          {
                            pm = currnode->a->u.eParameter.mode;
                            checkParams(&(currnode->a), lookup_type_find($2.symbol_entry));
                            if (pm == PASS_BY_VALUE)
                                GenQuad4(PAR_QUAD, $2.symbol_entry, "VALUE", NULL);
                            else
                                GenQuad4(PAR_QUAD, $2.symbol_entry, "REFERENCE", NULL);

                            switch ($2.symbol_entry->entryType) {
                                case ENTRY_CONSTANT:
                                case ENTRY_FUNCTION:
                                    break;
                                case ENTRY_PARAMETER:
                                    offset = $2.symbol_entry->u.eParameter.offset;
                                    break;
                                case ENTRY_VARIABLE:
                                    offset = $2.symbol_entry->u.eVariable.offset;
                                    break;
                                case ENTRY_TEMPORARY:
                                    offset = $2.symbol_entry->u.eTemporary.offset;
                                    break;
                            }
                            sprintf(buf, "dw %d\b", offset);
                            strcat(curr_param_node->prev_param_string, buf);
                        }
          opt6          { $$.symbol_entry = $4.symbol_entry; }
;

atom:
    T_id                            { 
                                        $$.symbol_entry = lookupEntry($1, LOOKUP_ALL_SCOPES, true);
                                        if ((logical_expr == 1) && (lookup_type_find($$.symbol_entry) == typeBoolean)) {
                                            $$.true_list = make_list(GenQuad2(EQ_QUAD, $$.symbol_entry, newConstant ("a", typeBoolean, 1), "-1", 0,""));
                                            $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                        }
                                    }
    | T_string                      { $$.symbol_entry = newConstant ("a", typeIArray(typeChar), $1); }
    | atom '[' expr ']'             {
                                        if (lookup_type_find($3.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                        $$.symbol_entry = newTemporary(typePointer(lookup_type_find($1.symbol_entry)));
                                        GenQuad(ARRAY_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry, 0,"");
                                    }
    | call                          {
                                        $$.symbol_entry = $1.symbol_entry;
                                        if ((logical_expr == 1) && (lookup_type_find($$.symbol_entry) == typeBoolean)) {
                                            $$.true_list = make_list(GenQuad2(EQ_QUAD, $$.symbol_entry, newConstant ("a", typeBoolean, 1), "-1", 0,""));
                                            $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                        }
                                    }
;

expr:
    atom                            { $$.symbol_entry = $1.symbol_entry;                          }
    | T_num                         { $$.symbol_entry = newConstant ("a", typeInteger, atoi($1)); } 
    | T_const                       { $$.symbol_entry = newConstant ("a", typeChar, $1);          } 
    | "true"                        {
                                        $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                        $$.true_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                        $$.false_list = emptylist();
                                    }
    | "false"                       {
                                        $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                        $$.true_list = emptylist();
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | expr '+' expr                 { 
                                        if ((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT)&&($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            new_const = ((int) $1.symbol_entry->u.eConstant.value.vInteger) + ((int) $3.symbol_entry->u.eConstant.value.vInteger);
                                            $$.symbol_entry = newConstant ("a", typeInteger, new_const);
                                        }
                                        else if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && (((int) $1.symbol_entry->u.eConstant.value.vInteger) == 0)) {
                                            $$.symbol_entry = $3.symbol_entry;
                                        }
                                        else if (($3.symbol_entry->entryType == ENTRY_CONSTANT) && (((int) $3.symbol_entry->u.eConstant.value.vInteger) == 0)) {
                                            $$.symbol_entry = $1.symbol_entry;
                                        }
                                        else {
                                            $$.arithmetic = 1;
                                            $$.symbol_entry = newTemporary(typeInteger);
                                            GenQuad(PLUS_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry, 0,""); 
                                        }
                                    }
    | expr '-' expr                 { 
                                        if ((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT)&&($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            new_const = ((int) $1.symbol_entry->u.eConstant.value.vInteger) - ((int) $3.symbol_entry->u.eConstant.value.vInteger);
                                            $$.symbol_entry = newConstant ("a", typeInteger, new_const);
                                        }
                                        else {
                                            $$.arithmetic = 1;
                                            $$.symbol_entry = newTemporary(typeInteger);
                                            GenQuad(MINUS_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry, 0,""); 
                                        }
                                    }
    | expr '*' expr                 { 
                                        if ((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT)&&($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            new_const = ((int) $1.symbol_entry->u.eConstant.value.vInteger) * ((int) $3.symbol_entry->u.eConstant.value.vInteger);
                                            $$.symbol_entry = newConstant ("a", typeInteger, new_const);
                                        }
                                        else if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && (((int) $1.symbol_entry->u.eConstant.value.vInteger) == 0)) {
                                            $$.symbol_entry = newConstant ("a", typeInteger, 0);
                                        }
                                        else if (($3.symbol_entry->entryType == ENTRY_CONSTANT) && (((int) $3.symbol_entry->u.eConstant.value.vInteger) == 0)) {
                                            $$.symbol_entry = newConstant ("a", typeInteger, 0);
                                        }
                                        else if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && (((int) $1.symbol_entry->u.eConstant.value.vInteger) == 1)) {
                                            $$.symbol_entry = $3.symbol_entry;
                                        }
                                        else if (($3.symbol_entry->entryType == ENTRY_CONSTANT) && (((int) $3.symbol_entry->u.eConstant.value.vInteger) == 1)) {
                                            $$.symbol_entry = $1.symbol_entry;
                                        }
                                        else {
                                            $$.arithmetic = 1;
                                            $$.symbol_entry = newTemporary(typeInteger);
                                            GenQuad(MULT_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry, 0,""); 
                                        }
                                    }
    | expr '/' expr                 { 
                                        if ((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT)&&($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            new_const = ((int) $1.symbol_entry->u.eConstant.value.vInteger) / ((int) $3.symbol_entry->u.eConstant.value.vInteger);
                                            $$.symbol_entry = newConstant ("a", typeInteger, new_const);
                                        }
                                        else {
                                            $$.arithmetic = 1;
                                            $$.symbol_entry = newTemporary(typeInteger);
                                            GenQuad(DIV_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry, 0,""); 
                                        }
                                    }
    | expr "mod" expr               { 
                                        if ((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT)&&($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            new_const = ((int) $1.symbol_entry->u.eConstant.value.vInteger) % ((int) $3.symbol_entry->u.eConstant.value.vInteger);
                                            $$.symbol_entry = newConstant ("a", typeInteger, new_const);
                                        }
                                        else {
                                            $$.arithmetic = 1;
                                            $$.symbol_entry = newTemporary(typeInteger);
                                            GenQuad(MOD_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry, 0,""); 
                                        }
                                    }
    | expr '=' expr                 {
                                        if (!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            if (lookup_type_find($1.symbol_entry) == typeBoolean) {
                                                if ($1.symbol_entry->u.eConstant.value.vBoolean == $3.symbol_entry->u.eConstant.value.vBoolean)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeInteger) {
                                                if ($1.symbol_entry->u.eConstant.value.vInteger == $3.symbol_entry->u.eConstant.value.vInteger)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeChar) {
                                                if ($1.symbol_entry->u.eConstant.value.vString == $3.symbol_entry->u.eConstant.value.vString)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            }
                                        } else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = make_list(GenQuad2(EQ_QUAD, $1.symbol_entry, $3.symbol_entry, "-1", 0,""));
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | expr '<' expr                 {
                                        if (!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            if (lookup_type_find($1.symbol_entry) == typeInteger) {
                                                if ($1.symbol_entry->u.eConstant.value.vInteger < $3.symbol_entry->u.eConstant.value.vInteger)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeChar) {
                                                if ($1.symbol_entry->u.eConstant.value.vString < $3.symbol_entry->u.eConstant.value.vString)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            }
                                        } else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = make_list(GenQuad2(LT_QUAD, $1.symbol_entry, $3.symbol_entry, "-1", 0,""));
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | expr '>' expr                 { 
                                        if (!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            if (lookup_type_find($1.symbol_entry) == typeInteger) {
                                                if ($1.symbol_entry->u.eConstant.value.vInteger > $3.symbol_entry->u.eConstant.value.vInteger)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeChar) {
                                                if ($1.symbol_entry->u.eConstant.value.vString > $3.symbol_entry->u.eConstant.value.vString)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            }
                                        } else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = make_list(GenQuad2(GT_QUAD, $1.symbol_entry, $3.symbol_entry, "-1", 0,""));
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | expr "<>" expr                { 
                                        if (!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            if (lookup_type_find($1.symbol_entry) == typeBoolean) {
                                                if ($1.symbol_entry->u.eConstant.value.vBoolean != $3.symbol_entry->u.eConstant.value.vBoolean)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeInteger) {
                                                if ($1.symbol_entry->u.eConstant.value.vInteger != $3.symbol_entry->u.eConstant.value.vInteger)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeChar) {
                                                if ($1.symbol_entry->u.eConstant.value.vString != $3.symbol_entry->u.eConstant.value.vString)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            }
                                        } else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = make_list(GenQuad2(NE_QUAD, $1.symbol_entry, $3.symbol_entry, "-1", 0,""));
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | expr "<=" expr                { 
                                        if (!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            if (lookup_type_find($1.symbol_entry) == typeBoolean) {
                                                if ($1.symbol_entry->u.eConstant.value.vBoolean <= $3.symbol_entry->u.eConstant.value.vBoolean)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeInteger) {
                                                if ($1.symbol_entry->u.eConstant.value.vInteger <= $3.symbol_entry->u.eConstant.value.vInteger)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeChar) {
                                                if ($1.symbol_entry->u.eConstant.value.vString <= $3.symbol_entry->u.eConstant.value.vString)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            }
                                        } else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = make_list(GenQuad2(LE_QUAD, $1.symbol_entry, $3.symbol_entry, "-1", 0,""));
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | expr ">=" expr                {
                                        if (!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                        if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($3.symbol_entry->entryType == ENTRY_CONSTANT)) {
                                            if (lookup_type_find($1.symbol_entry) == typeBoolean) {
                                                if ($1.symbol_entry->u.eConstant.value.vBoolean >= $3.symbol_entry->u.eConstant.value.vBoolean)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeInteger) {
                                                if ($1.symbol_entry->u.eConstant.value.vInteger >= $3.symbol_entry->u.eConstant.value.vInteger)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            } else if (lookup_type_find($1.symbol_entry) == typeChar) {
                                                if ($1.symbol_entry->u.eConstant.value.vString >= $3.symbol_entry->u.eConstant.value.vString)
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                                else
                                                    $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                            }
                                        } else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = make_list(GenQuad2(GE_QUAD, $1.symbol_entry, $3.symbol_entry, "-1", 0,""));
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | expr                          { 
                                        if (lookup_type_find($1.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");
                                        backpatch($1.true_list,nextquad);
                                    }
          "and" expr                { 
                                        if (lookup_type_find($4.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");                                      
                                        if ((($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($1.symbol_entry->u.eConstant.value.vBoolean == 0) )|| (($4.symbol_entry->entryType == ENTRY_CONSTANT) && ($4.symbol_entry->u.eConstant.value.vBoolean == 0)))
                                            $$.symbol_entry = newConstant ("a", typeBoolean, 0);
                                        else if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($1.symbol_entry->u.eConstant.value.vBoolean == 1))
                                            $$.symbol_entry = $4.symbol_entry;
                                        else if (($4.symbol_entry->entryType == ENTRY_CONSTANT) && ($4.symbol_entry->u.eConstant.value.vBoolean == 1))
                                            $$.symbol_entry = $1.symbol_entry;
                                        else
                                            $$.symbol_entry = newTemporary(typeBoolean);                                      
                                        $$.false_list = merge($1.false_list, $4.false_list);
                                        $$.true_list = $4.true_list;
                                    }
    | expr                          {
                                        if (lookup_type_find($1.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");
                                        backpatch($1.false_list,nextquad);
                                    }
          "or" expr                 {
                                        if (lookup_type_find($4.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");                                      
                                        if ((($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($1.symbol_entry->u.eConstant.value.vBoolean == 1) )|| (($4.symbol_entry->entryType == ENTRY_CONSTANT) && ($4.symbol_entry->u.eConstant.value.vBoolean == 1)))
                                            $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                        else if (($1.symbol_entry->entryType == ENTRY_CONSTANT) && ($1.symbol_entry->u.eConstant.value.vBoolean == 0))
                                            $$.symbol_entry = $4.symbol_entry;
                                        else if (($4.symbol_entry->entryType == ENTRY_CONSTANT) && ($4.symbol_entry->u.eConstant.value.vBoolean == 0))
                                            $$.symbol_entry = $1.symbol_entry;
                                        else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = merge($1.true_list, $4.true_list);
                                        $$.false_list = $4.false_list;
                                    }
    | expr '#' expr                 { 
                                        if (lookup_type_find($3.symbol_entry)->kind != TYPE_LIST) {
                                            if (lookup_type_find($3.symbol_entry)->kind == TYPE_POINTER) {
                                                if (lookup_type_find($3.symbol_entry)->refType->refType->kind != TYPE_LIST) {      
                                                    ERROR("$3.symbol entry must be array of lists, not array of another type");
                                                }
                                            } else
                                                ERROR("$3.symbol entry must be of type list or array of lists");
                                        }
                                        if (lookup_type_find($3.symbol_entry)->refType != typeVoid) {
                                            if (cons_check(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)) == 0)
                                                ERROR("exprs must be of type t and list[t] respectively");
                                            $$.symbol_entry = newTemporary(typeList(lookup_type_find($3.symbol_entry)->refType));                
                                        } else                                    
                                            $$.symbol_entry = newTemporary(typeList(lookup_type_find($1.symbol_entry)));
                                        temp_param_node = (prev_params *) new(sizeof(prev_params));
                                        if (curr_param_node == NULL) {
                                            temp_param_node->prev_param_string = strdup("");
                                            temp_param_node->prev = NULL;
                                        } else {
                                            temp_param_node->prev_param_string = strdup(curr_param_node->prev_param_string);
                                            temp_param_node->prev = curr_param_node;
                                        }
                                        curr_param_node = temp_param_node;
                                        if ((lookup_type_find($1.symbol_entry)->kind == TYPE_LIST || lookup_type_find($1.symbol_entry)->kind == TYPE_IARRAY)) {
                                            GenQuad4(PAR_QUAD, $1.symbol_entry, "REFERENCE", NULL);
                                            GenQuad4(PAR_QUAD, $3.symbol_entry, "REFERENCE", NULL);
                                            GenQuad4(PAR_QUAD, $$.symbol_entry, "RET", NULL);
                                            currentScope->unit_flag = 1;
                                            if (curr_param_node == NULL || curr_param_node->prev == NULL)
                                                GenQuad2(CALL_QUAD, NULL, NULL, "consp", 4, "");
                                            else
                                                GenQuad2(CALL_QUAD, NULL, NULL, "consp", 4, curr_param_node->prev->prev_param_string);
                                            externs[15] = 1;
                                        }
                                        else {
                                            GenQuad4(PAR_QUAD, $1.symbol_entry, "VALUE", NULL);
                                            GenQuad4(PAR_QUAD, $3.symbol_entry, "VALUE", NULL);
                                            GenQuad4(PAR_QUAD, $$.symbol_entry, "RET", NULL);
                                            currentScope->unit_flag = 1;
                                            if (curr_param_node == NULL || curr_param_node->prev == NULL)
                                                GenQuad2(CALL_QUAD, NULL, NULL, "consv", 4, "");
                                            else
                                                GenQuad2(CALL_QUAD, NULL, NULL, "consv", 4, curr_param_node->prev->prev_param_string);
                                            externs[16] = 1;
                                        }
                                        temp_param_node = curr_param_node;
                                        curr_param_node = curr_param_node->prev;
                                        delete(temp_param_node);
                                    }
    | '-' expr         %prec UMINUS { 
                                        if (lookup_type_find($2.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                        if ($2.symbol_entry->entryType == ENTRY_CONSTANT) {
                                            new_const = 0 - ((int) $2.symbol_entry->u.eConstant.value.vInteger);
                                            $$.symbol_entry = newConstant ("a", typeInteger, new_const);
                                        }
                                        else {
                                            $$.symbol_entry = newTemporary(typeInteger);
                                            GenQuad(MINUS_QUAD, newConstant ("a", typeInteger, 0), $2.symbol_entry, $$.symbol_entry, 0,"");
                                        }
                                    }
    | '+' expr         %prec UPLUS  {
                                        if (lookup_type_find($2.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                        $$.symbol_entry = $2.symbol_entry;
                                    }
    | '(' expr ')'                  {
                                        $$.symbol_entry = $2.symbol_entry;
                                        $$.true_list = $2.true_list;
                                        $$.false_list = $2.false_list;
                                    }
    | "not" expr                    {
                                        if (lookup_type_find($2.symbol_entry) != typeBoolean)
                                            ERROR("expr must be of type bool");
                                        if (($2.symbol_entry->entryType == ENTRY_CONSTANT) && ($2.symbol_entry->u.eConstant.value.vBoolean == 0) )
                                            $$.symbol_entry = newConstant ("a", typeBoolean, 1);
                                        else if (($2.symbol_entry->entryType == ENTRY_CONSTANT) && ($2.symbol_entry->u.eConstant.value.vBoolean == 1) )
                                            $$.symbol_entry = newConstant ("a", typeBoolean, 0);                                      
                                        else
                                            $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = $2.false_list;
                                        $$.false_list = $2.true_list;
                                    }
    | "new" type '[' expr ']'       {
                                        if (lookup_type_find($4.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                        S = newConstant ("a", typeInteger, custom_sizeof($2.refT));
                                        W = newTemporary(typeInteger);
                                        GenQuad(MULT_QUAD, $4.symbol_entry, S, W, 0,"");
                                        GenQuad4(PAR_QUAD, W, "VALUE", NULL);
                                        if ($2.refT->kind == TYPE_IARRAY || $2.refT->kind == TYPE_LIST)
                                            $$.pointer = 2; /*array of pointers*/
                                        else
                                            $$.pointer = 1; /*array of values*/
                                        $$.symbol_entry = newTemporary(typeIArray($2.refT));
                                    }
    | "nil"                         { $$.symbol_entry = newTemporary(typeList(typeVoid)); }
    | "nil?" '(' expr ')'           {
                                        if (lookup_type_find($3.symbol_entry)->kind != TYPE_LIST) {
                                            if (lookup_type_find($3.symbol_entry)->kind == TYPE_POINTER) {
                                                if (lookup_type_find($3.symbol_entry)->refType->refType->kind != TYPE_LIST) {      
                                                    ERROR("$3.symbol entry must be array of lists, not array of another type");
                                                }
                                            } else
                                                ERROR("$3.symbol entry must be of type list or array of lists");
                                        }
                                        $$.symbol_entry = newTemporary(typeBoolean);
                                        $$.true_list = make_list(GenQuad2(ISNIL_QUAD, NULL, $3.symbol_entry, "-1", 0,""));
                                        $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1", 0,""));
                                    }
    | "head" '(' expr ')'           {
                                        if (lookup_type_find($3.symbol_entry)->kind != TYPE_LIST) {
                                            if (lookup_type_find($3.symbol_entry)->kind == TYPE_POINTER) {
                                                if (lookup_type_find($3.symbol_entry)->refType->refType->kind != TYPE_LIST) {      
                                                    ERROR("$3.symbol entry must be array of lists, not array of another type");
                                                }
                                            } else
                                                ERROR("$3.symbol entry must be of type list or array of lists");
                                        }
                                        if (lookup_type_find($3.symbol_entry)->refType == typeVoid)
                                            ERROR("The list must not be empty");
                                        $$.symbol_entry = newTemporary(lookup_type_find($3.symbol_entry)->refType);
                                        temp_param_node = (prev_params *) new(sizeof(prev_params));
                                        if (curr_param_node == NULL) {
                                            temp_param_node->prev_param_string = strdup("");
                                            temp_param_node->prev = NULL;
                                        } else {
                                            temp_param_node->prev_param_string = strdup(curr_param_node->prev_param_string);
                                            temp_param_node->prev = curr_param_node;
                                        }
                                        curr_param_node = temp_param_node;
                                        GenQuad4(PAR_QUAD, $3.symbol_entry, "VALUE", NULL);
                                        GenQuad4(PAR_QUAD, $$.symbol_entry, "RET", NULL);
                                        currentScope->unit_flag = 1;
                                        if (curr_param_node == NULL || curr_param_node->prev == NULL)
                                            GenQuad2(CALL_QUAD, NULL, NULL, "head", 2, "");
                                        else
                                            GenQuad2(CALL_QUAD, NULL, NULL, "head", 2, curr_param_node->prev->prev_param_string);
                                        externs[17] = 1;
                                        temp_param_node = curr_param_node;
                                        curr_param_node = curr_param_node->prev;
                                        delete(temp_param_node);
                                    }
    | "tail" '(' expr ')'           {
                                        if (lookup_type_find($3.symbol_entry)->kind != TYPE_LIST) {
                                            if (lookup_type_find($3.symbol_entry)->kind == TYPE_POINTER) {
                                                if (lookup_type_find($3.symbol_entry)->refType->refType->kind != TYPE_LIST) {      
                                                    ERROR("$3.symbol entry must be array of lists, not array of another type");
                                                }
                                            } else
                                                ERROR("$3.symbol entry must be of type list or array of lists");
                                        }
                                        if (lookup_type_find($3.symbol_entry)->refType == typeVoid)
                                            ERROR("The list must not be empty");
                                        $$.symbol_entry = newTemporary(typeList(lookup_type_find($3.symbol_entry)->refType));
                                        temp_param_node = (prev_params *) new(sizeof(prev_params));
                                        if (curr_param_node == NULL) {
                                            temp_param_node->prev_param_string = strdup("");
                                            temp_param_node->prev = NULL;
                                        } else {
                                            temp_param_node->prev_param_string = strdup(curr_param_node->prev_param_string);
                                            temp_param_node->prev = curr_param_node;
                                        }
                                        curr_param_node = temp_param_node;
                                        GenQuad4(PAR_QUAD, $3.symbol_entry, "VALUE", NULL);
                                        GenQuad4(PAR_QUAD, $$.symbol_entry, "RET", NULL);
                                        currentScope->unit_flag = 1;
                                        if (curr_param_node == NULL || curr_param_node->prev == NULL)
                                            GenQuad2(CALL_QUAD, NULL, NULL, "tail", 2, "");
                                        else
                                            GenQuad2(CALL_QUAD, NULL, NULL, "tail", 2, curr_param_node->prev->prev_param_string);
                                        externs[20] = 1;
                                        temp_param_node = curr_param_node;
                                        curr_param_node = curr_param_node->prev;
                                        delete(temp_param_node);
                                    }
;

%%



void yyerror (const char *msg)
{
    ERROR("parser said, %s", msg);
}

void usage (char *s)
{
    fprintf(stderr, "Usage: %s [-i | -f | filename.tony\n", s);
    fprintf(stderr, "\nIf -i or -f is specified in the command line, then\n");
    fprintf(stderr, "the standard input is used as the Tony source file.\n");
    fprintf(stderr, "\t-i: Output the intermediate code to stdout\n");
    fprintf(stderr, "\t-f: Output the final assembly code to stdout\n");
    fprintf(stderr, "\nIf a source filename is specified, then\n");
    fprintf(stderr, "filename.imm and filename.asm are produced.\n");
    exit(1);
}

int main (int argc, char *argv[])
{
    int i, opt_i = 0, opt_f = 0;
    char fname[255], *ext, c;

    /* Parse arguments and initialize compiler */
    opterr = 0;
    while ((c = getopt(argc, argv, "if")) > 0) {
        switch (c) {
        case 'i':
            opt_i = 1;
            break;
        case 'f':
            opt_f = 1;
            break;
        default:
            fprintf(stderr, "`-%c': Unknown option\n", optopt);
            exit(1);
        }
    }

    ProduceInterm = ProduceFinal = 1;

    if (!opt_i && !opt_f) {
        /* No -i or -f argument, a file name is required */
        if (optind != argc-1)
            usage(argv[0]);
        strncpy(fname, argv[optind], 255);
        if (strlen(argv[optind]) > 254)
            fname[254] = '\0';
        
        /* Set up the input and output files */
        if ( !(ext = strstr(fname, ".tony"))) {
            fprintf(stderr, "The input filename's extension must be .tony\n");
            exit(1);
        }
        if ( !(yyin = fopen(fname, "r"))) {
            fprintf(stderr, "Cannot open source file `%s'\n", fname);
            exit(1);
        }

        strcpy(ext, ".imm");
        if ( !(imm_stream = fopen(fname, "w+"))) {
            fprintf(stderr, "Cannot open output file `%s'\n", fname);
            exit(1);
        }

        strcpy(ext, ".asm");
        if ( !(final_stream = fopen(fname, "w+"))) {
            fprintf(stderr, "Cannot open output file `%s'\n", fname);
            exit(1);
        }
    
        strcpy(ext, ".tony");
        filename = strdup(fname);
    } else {
        if ((opt_i && opt_f) || optind != argc)
            usage(argv[0]);
        
        /* Set up the input and output files */
        yyin = stdin;
        if (opt_i) {
            imm_stream = stdout;
            ProduceFinal = 0;
        } else {
            imm_stream = fopen("pure_quads.txt", "w+");
            final_stream = stdout;
            ProduceInterm =0;
        }
        filename = strdup("standard input");
    }

    fp1 = fopen("quads.txt", "w+");
    unit_counter = 0;

    for (i = 0; i < 21; i++)
        externs[i] = 0;

    if (yyparse() == 0) {
        printf("yyparse returned 0. Everything's all right.\n");
    }
    else
        printf("Ooops. Something is wrong. Check the error message above.\n");

    fclose(fp1);
    fclose(imm_stream);

    if (ProduceInterm == 0) {
        imm_stream = fopen("pure_quads.txt", "r");
    }
    fp1 = fopen("quads.txt", "r");
    if (!opt_i && !opt_f) {
        strcpy(ext, ".imm");
        imm_stream = fopen(fname, "r");
    }
    generator(externs, offsets, final_stream, fp1, imm_stream);
    destroySymbolTable();

    /* Clean up all the mess */
    if (ProduceInterm)
    fclose(imm_stream);
    if (ProduceFinal) {
        fclose(final_stream);
        remove("quads.txt");
        remove("pure_quads.txt");
    } else {
        remove("quads.txt");
    }
    fclose(fp1);

    return 0;
}
