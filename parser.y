%{
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "quads.h"
#include "error.h"
#include "symbol.h"
#include "general.h"


typedef struct node node;

struct node{
    SymbolEntry * a;
    node * prev;
};

node * currnode, * temp;
int flag;
SymbolEntry * p, * b;
Type type, refType;
PassMode pMode, pm;
label_list temp1, temp2, temp3, temp4, temp5, temp6, temp7;

Type lookup_type_find(SymbolEntry * p){
        if(p == NULL)
                ERROR("I am here\n");
    Type value;
    switch(p->entryType){
        case ENTRY_CONSTANT:
            return p->u.eConstant.type;
            break;
        case ENTRY_FUNCTION:
            return p->u.eFunction.resultType;
            break;
        case ENTRY_PARAMETER:
            return p->u.eParameter.type;
            break;
        case ENTRY_VARIABLE:
            return p->u.eVariable.type;
            break;
        case ENTRY_TEMPORARY:
            return p->u.eTemporary.type;
            break;
    }
}

Type lookup_type_in_arrays(Type p){
    while (p->kind == TYPE_IARRAY)
        p = p->refType;
    return p;
}

Type lookup_in_curScope(){
    return p->u.eFunction.resultType;
}

void ERROR (const char * fmt, ...);

void checkParams(SymbolEntry ** p, Type t){
    if ( *p == NULL)
        ERROR("More arguments than expected");
    else if (!equalType(lookup_type_find(*p),t))
        if(t->kind == TYPE_IARRAY && equalType(lookup_type_find(*p),t->refType))
            *p = (*p)->u.eParameter.next;
        else
            ERROR("Typical and real parameters type mismatch");
    else
        *p = (*p)->u.eParameter.next;
}

void checkNoParams(SymbolEntry *p){
    if ( p != NULL)
        ERROR("Less arguments than expected");
}

void yyerror (const char *msg);

%}

%locations

%union {
        struct{
                PassMode pm;
                Type refT;
                label_list true_list;
                label_list false_list;
        label_list next_list;
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
%token<n> T_num
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

%type<a> type opt1 opt3 expr atom call stmt stmt_list elsif_list else_list simple opt5 opt6


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
        destroySymbolTable();
    }
;

func_def:
    { flag = 0; }
    "def" header  ':' func_def_list stmt_list "end"
    {
                GenQuad3(ENDU_QUAD, currentScope->name, NULL, NULL);
                print_all_quads();
        closeScope();
    }
;

func_def_list:
    /* nothing */
    | func_def_list func_def
    | func_def_list func_decl
    | func_def_list var_def
;

stmt_list: /* needs fixing with next_list */
    /* nothing */
    | stmt_list stmt
;

header:
    opt1 T_id
    {   /* fprintf(stderr,"%s \n", $2); */
                GenQuad3(UNIT_QUAD, $2, NULL, NULL);
                p = newFunction($2);
        if(flag){
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
    |formal
    | opt2 ';' formal
;


formal:
    opt3 type T_id
    {   /* fprintf(stderr,"%s \n", $3); */
        newParameter($3, $2.refT, $1.pm, p);
        type = $2.refT;
        pMode = $1.pm;
    }
    | formal ',' T_id
    {
      newParameter($3, type, pMode, p);
    }
;

opt3:
                                    { $$.pm = PASS_BY_VALUE;       }
    | "ref"                         { $$.pm = PASS_BY_REFERENCE;   }
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
    {   /* fprintf(stderr,"%s \n", $2); */
        newVariable($2, $1.refT);
        type = $1.refT;
    }
    | var_def ',' T_id
    {
      newVariable($3, type);
    }
;

stmt:
    simple              { $$.next_list = $1.next_list; }
    | "exit"            { $$.next_list = emptylist();  }
    | "return" expr     { if (!equalType(lookup_type_find($2.symbol_entry), lookup_in_curScope()))
                                ERROR("Wrong type for return value");
                          GenQuad(RETV_QUAD, $2.symbol_entry, NULL, NULL);
                          GenQuad(RET_QUAD, NULL, NULL, NULL);
                        }
    | "if" expr         { if (lookup_type_find($2.symbol_entry) != typeBoolean)
                                ERROR("if exprs must be of type bool");
                          backpatch($2.true_list, nextquad);
                          temp1 = $2.false_list;
                          temp2 = emptylist();
                        }
      ':' stmt_list elsif_list else_list "end"
                        { temp6 = merge(temp1,$5.next_list);
                          temp7 = merge(temp6,$6.next_list);
                          temp6 = merge(temp7,$7.next_list);
                          $$.next_list = merge(temp6, temp2);
                        }
    | "for" simple_list ';'
                        {
                          temp1 = nextquad;
                        }
       expr ';' simple_list ':'
                        { if (lookup_type_find($5.symbol_entry) != typeBoolean)
                                ERROR("for exprs must be of type bool");
                          backpatch($5.true_list,nextquad);
                        }
       stmt_list "end"
                        { backpatch($10.next_list,temp1);
                          GenQuad2(JMP_QUAD, NULL, NULL, "-1");
                          $$.next_list = $5.false_list;
                        }
;

elsif_list:
    /* nothing */       { $$.next_list = emptylist();}
    | "elsif" expr      { if (lookup_type_find($2.symbol_entry) != typeBoolean)
                                ERROR("elsif exprs must be of type bool");
                          backpatch($2.true_list, nextquad);
                          temp1 = $2.false_list;
                          temp4 = temp1; /* that is because we need $2.false_list for the else_list */
                          temp2 = emptylist();
                        }
      ':' stmt_list     { temp1 = make_list(nextquad);
                          GenQuad2(JMP_QUAD, NULL, NULL, "-1");
                          backpatch($2.false_list, nextquad);
                        }
      elsif_list        { temp2 = $7.next_list;
                          temp5 = $5.next_list; /* that is because we need $5.next_list for the else_list */
                          temp3 = merge(temp1, $5.next_list);
                          $$.next_list = merge(temp3, temp2);
                        }
;

else_list:
    /* nothing */       { $$.next_list = emptylist();}
    | "else"            { temp1 = make_list(nextquad);
                          GenQuad2(JMP_QUAD, NULL, NULL, "-1");
                          backpatch(temp4, nextquad);
                        }
      ':' stmt_list     { temp2 = $4.next_list;
                          temp3 = merge(temp1, temp5);
                          $$.next_list = merge(temp3, temp2);
                        }
;

simple:
    "skip"              { $$.next_list = emptylist(); }
    | atom ":=" expr    { if(!equalType(lookup_type_in_arrays(lookup_type_find($1.symbol_entry)), lookup_type_in_arrays(lookup_type_find($3.symbol_entry))))
                                ERROR("not the same type of exprs");
                          GenQuad(ASSIGN_QUAD, $3.symbol_entry, NULL, $1.symbol_entry);
                          $$.next_list = emptylist();
                        }
    | call              { $$.next_list = emptylist(); }
;

simple_list: /* may need fixing with next_list */
    simple
    | simple_list ',' simple
;

call:
    T_id                { temp = (node *) new(sizeof(node));
                          temp->prev = currnode;
                          currnode = temp;
                          b = lookupEntry($1, LOOKUP_ALL_SCOPES, true); currnode->a = b->u.eFunction.firstArgument;
                        }
    '(' opt5 ')'        { $$.symbol_entry = $4.symbol_entry;
                          temp = currnode;
                          currnode = currnode->prev;
                          delete(temp);
                        }
;


opt5:
    /* nothing */       { checkNoParams(currnode->a);
                          if(b->u.eFunction.resultType != typeVoid){
                                $$.symbol_entry = newTemporary(b->u.eFunction.resultType);
                                GenQuad4(PAR_QUAD, $$.symbol_entry, "RET", NULL);
                          }
                          else
                                $$.symbol_entry = b;
                          GenQuad(CALL_QUAD, NULL, NULL, b);
                        }
    | expr              {
                          pm = currnode->a->u.eParameter.mode;
                          checkParams(&(currnode->a), lookup_type_find($1.symbol_entry));
                          if (pm == PASS_BY_VALUE)
                                GenQuad4(PAR_QUAD, $1.symbol_entry, "VALUE", NULL);
                          else
                                GenQuad4(PAR_QUAD, $1.symbol_entry, "REFFERENCE", NULL);
                          $$.symbol_entry = b;
                        }
    | opt5 ',' expr     {
                          pm = currnode->a->u.eParameter.mode;
                          checkParams(&(currnode->a), lookup_type_find($3.symbol_entry));
                          if (pm == PASS_BY_VALUE)
                                GenQuad4(PAR_QUAD, $3.symbol_entry, "VALUE", NULL);
                          else
                                GenQuad4(PAR_QUAD, $3.symbol_entry, "REFFERENCE", NULL);
                          $$.symbol_entry = $1.symbol_entry;
                        }
;

atom:
    T_id                            { $$.symbol_entry = lookupEntry($1, LOOKUP_ALL_SCOPES, true); }
    | T_string                      { $$.symbol_entry = newConstant ("a", typeIArray(typeChar), $1); }
    | atom '[' expr ']'             { if(lookup_type_find($3.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                      $$.symbol_entry = $1.symbol_entry;
                                    }
    | call                          { $$.symbol_entry = $1.symbol_entry; }
;

expr:
    atom                            { $$.symbol_entry = $1.symbol_entry; }
    | T_num                         { $$.symbol_entry = newConstant ("a", typeInteger, atoi($1)); } /* atoi can also go to lexer, I don't know what is better */
    | T_const                       { $$.symbol_entry = newConstant ("a", typeChar, $1);    } /* Here we may have a problem to solve */
    | "true"                        { $$.symbol_entry = newConstant ("a", typeBoolean, 1);  }
    | "false"                       { $$.symbol_entry = newConstant ("a", typeBoolean, 0);  }
    | expr '+' expr                 { if((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                      $$.symbol_entry = newTemporary(typeInteger);
                                      GenQuad(PLUS_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry); /* Added Today */
                                    }
    | expr '-' expr                 { if((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                      $$.symbol_entry = newTemporary(typeInteger);
                                      GenQuad(MINUS_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry); /* Added Today */
                                    }
    | expr '*' expr                 { if((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                      $$.symbol_entry = newTemporary(typeInteger);
                                      GenQuad(MULT_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry); /* Added Today */
                                    }
    | expr '/' expr                 { if((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                      $$.symbol_entry = newTemporary(typeInteger);
                                      GenQuad(DIV_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry); /* Added Today */
                                    }
    | expr "mod" expr               { if((lookup_type_find($1.symbol_entry) != typeInteger) || (lookup_type_find($3.symbol_entry) != typeInteger))
                                            ERROR("exprs must be of type int");
                                      $$.symbol_entry = newTemporary(typeInteger);
                                      GenQuad(MOD_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry); /* Added Today */
                                    }
    | expr '=' expr                 { if(!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = make_list(GenQuad2(EQ_QUAD, $1.symbol_entry, $3.symbol_entry, "-1"));
                                      $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1"));
                                    }
    | expr '<' expr                 { if(!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = make_list(GenQuad2(LT_QUAD, $1.symbol_entry, $3.symbol_entry, "-1"));
                                      $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1"));
                                    }
    | expr '>' expr                 { if(!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = make_list(GenQuad2(GT_QUAD, $1.symbol_entry, $3.symbol_entry, "-1"));
                                      $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1"));
                                    }
    | expr "<>" expr                { if(!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = make_list(GenQuad2(NE_QUAD, $1.symbol_entry, $3.symbol_entry, "-1"));
                                      $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1"));
                                    }
    | expr "<=" expr                { if(!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = make_list(GenQuad2(LE_QUAD, $1.symbol_entry, $3.symbol_entry, "-1"));
                                      $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1"));
                                    }
    | expr ">=" expr                { if(!equalType(lookup_type_find($1.symbol_entry), lookup_type_find($3.symbol_entry)))
                                            ERROR("not the same type of exprs");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = make_list(GenQuad2(GE_QUAD, $1.symbol_entry, $3.symbol_entry, "-1"));
                                      $$.false_list = make_list(GenQuad2(JMP_QUAD, NULL, NULL, "-1"));
                                    }
    | expr                          { if(lookup_type_find($1.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");
                                      backpatch($1.true_list,nextquad);
                                    }
          "and" expr                { if(lookup_type_find($4.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.false_list = merge($1.false_list, $4.false_list);
                                      $$.true_list = $4.true_list;
                                    }
    | expr                          { if(lookup_type_find($1.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");
                                      backpatch($1.false_list,nextquad);
                                    }
          "or" expr                 { if(lookup_type_find($4.symbol_entry) != typeBoolean)
                                            ERROR("exprs must be of type bool");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = merge($1.true_list, $4.true_list);
                                      $$.false_list = $4.false_list;
                                    }
    | expr '#' expr                 { if((lookup_type_find($3.symbol_entry)->kind != TYPE_LIST) || (lookup_type_find($1.symbol_entry) != lookup_type_find($3.symbol_entry)->refType))
                                            ERROR("exprs must be of type t and list[t] respectively") ;
                                      $$.symbol_entry = newTemporary(typeList(lookup_type_find($3.symbol_entry)->refType));
                                      GenQuad(LIST_QUAD, $1.symbol_entry, $3.symbol_entry, $$.symbol_entry); /* Added Today */
                                    }
    | '-' expr         %prec UMINUS { if(lookup_type_find($2.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                      $$.symbol_entry = newTemporary(typeInteger);
                                      GenQuad(MINUS_QUAD, $2.symbol_entry, NULL, $$.symbol_entry); /* Added Today */
                                    }
    | '+' expr         %prec UPLUS  { if(lookup_type_find($2.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                      $$.symbol_entry = newTemporary(typeInteger);
                                      GenQuad(PLUS_QUAD, $2.symbol_entry, NULL, $$.symbol_entry); /* Added Today */
                                    }
    | '(' expr ')'                  { $$.symbol_entry = $2.symbol_entry; }
    | "not" expr                    { if(lookup_type_find($2.symbol_entry) != typeBoolean)
                                            ERROR("expr must be of type bool");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      $$.true_list = $2.false_list;
                                      $$.false_list = $2.true_list;
                                    }
    | "new" type '[' expr ']'       { if(lookup_type_find($4.symbol_entry) != typeInteger)
                                            ERROR("expr must be of type int");
                                      $$.symbol_entry = newTemporary(typeIArray($2.refT));
                                      GenQuad(ARRAY_QUAD, $2.symbol_entry, $4.symbol_entry, $$.symbol_entry); /* Added Today */
                                    }
    | "nil"                         { $$.symbol_entry = newTemporary(typeList(typeVoid)); }
    | "nil?" '(' expr ')'           { if(lookup_type_find($3.symbol_entry)->kind != TYPE_LIST)
                                            ERROR("expr must be of type list");
                                      $$.symbol_entry = newTemporary(typeBoolean);
                                      GenQuad(ISNIL_QUAD, $3.symbol_entry, NULL, $$.symbol_entry); /* Added Today */
                                    }
    | "head" '(' expr ')'           { if(lookup_type_find($3.symbol_entry)->kind != TYPE_LIST)
                                            ERROR("expr must be of type list");
                                      $$.symbol_entry = newTemporary(lookup_type_find($3.symbol_entry)->refType);
                                      GenQuad(HEAD_QUAD, $3.symbol_entry, NULL, $$.symbol_entry); /* Added Today */
                                    }
    | "tail" '(' expr ')'           { if(lookup_type_find($3.symbol_entry)->kind != TYPE_LIST)
                                            ERROR("expr must be of type list");
                                      $$.symbol_entry = newTemporary(typeList(lookup_type_find($3.symbol_entry)->refType));
                                      GenQuad(TAIL_QUAD, $3.symbol_entry, NULL, $$.symbol_entry); /* Added Today */
                                    }
;

%%

void ERROR (const char * fmt, ...);

void yyerror (const char *msg)
{
  ERROR("parser said, %s", msg);
}

int main ()
{
  temp1 = emptylist();
  temp2 = emptylist();
  temp3 = emptylist();
  temp4 = emptylist();
  temp5 = emptylist();
  temp6 = emptylist();
  temp7= emptylist();

  if (yyparse()==0){
    printf("yyparse returned 0. Everything's all right.\n");
  }
  else
    printf("Ooops. Something is wrong. Check the error message above.\n");
  return 0;
}
