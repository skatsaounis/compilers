%{
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "quads.h"
#include "symbol.h"
#include "parser.h"


int yycolumn = 1;

#define T_eof   0
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;\
    yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1; \
    yycolumn += yyleng; \

/*int lineno = 1;
int columnno = 1;*/
int neslevel = 0;

void ERROR (const char * fmt, ...);


%}

%option yylineno

Lc [A-Z]
Ls [a-z]
D  [0-9]
X  [0-9]|([a-f]|[A-F])
W  [ \r]
E  ["n""t""r""0"\'\"\\]
%x COMMENT

%%

"and" 					{ return T_and; }  /* Keywords munch */
"bool" 					{ return T_bool; }
"char" 					{ return T_char; }
"decl" 					{ return T_decl; }
"def" 					{ return T_def; }
"else" 					{ return T_else; }
"elsif"					{ return T_elsif; }
"end" 					{ return T_end; }
"exit" 					{ return T_exit; }
"false" 				{ return T_false; }
"for" 					{ return T_for; }
"head" 					{ return T_head; }
"if" 					{ return T_if; }
"int" 					{ return T_int; }
"list" 					{ return T_list; } 
"mod" 					{ return T_mod; }
"new" 					{ return T_new; }
"nil" 					{ return T_nil; }
"nil?" 					{ return T_nilq; }
"not" 					{ return T_not; }
"or" 					{ return T_or; }
"ref" 					{ return T_ref; } 
"return"	 			{ return T_return; } 
"skip" 					{ return T_skip; }
"tail" 					{ return T_tail; }
"true" 					{ return T_true; }

({Ls}|{Lc})({Ls}|{Lc}|{D}|"_"|"?")*	{ yylval.s = strdup(yytext); /*alla3a auto*/
					  return T_id; } /* Variables munch */

{D}+					{ yylval.s = strdup(yytext);
					  return T_num; } /* Numbers munch */

\'(\\{E}|"x"{X}{X}|.)\'			{ yylval.s = strdup(yytext);
					  return T_const; }

[\+\-\*/#=<>]  				{ return yytext[0]; } /* Symbolic Operators munch */
"<>"					{ return T_nequal; }
"<="					{ return T_lequal; }
">="					{ return T_gequal; }

[\(\)\[\]\,\;\:]			{ return yytext[0]; } /* Separators munch */
":="					{ return T_assignor; }

\"([^\'\"\r\n\\]|\\{E})*\"		{ yylval.s = strdup(yytext); 
					  return T_string; } /* Strings munch */
{W}+					{ /*columnno++;*/ }
\t   					{ yycolumn += 9 - (yycolumn % 8); }
\n      				{ /* nothing lineno++; columnno = 1;*/ yycolumn = 1; }
\%.*\n  				{ /*lineno++; columnno = 1;*/ } /* One line Comment munch */

"<*"					{ neslevel++; BEGIN(COMMENT); }
<COMMENT>"<*"				{ neslevel++; }
<COMMENT>"*>"				{ neslevel--; if (!neslevel) BEGIN(INITIAL); }
<COMMENT>\n				{ /*lineno++; columnno = 1;*/ yycolumn = 1; }
<COMMENT>"*"				{ /* nothing */ }
<COMMENT>[^<*\n]+			{ /* nothing */ }
<COMMENT>.				{ /* nothing */ }

<<EOF>> 				{ return T_eof; }
.       				{ ERROR("illegal character: '%c' (ASCII: %d)", yytext[0], yytext[0]); }

%%

void ERROR (const char * fmt, ...)
{
   va_list ap;

   va_start(ap, fmt);
   fprintf(stderr, "Line %d, Column %d, error: ", yylloc.first_line,yylloc.first_column);
   vfprintf(stderr, fmt, ap);
   fprintf(stderr, "\n");
   va_end(ap);
   exit(1);
}


/*int main ()
{
  int token;
  do {
    token = yylex();
    columnno += strlen(yytext);
    printf("token=%d, lexeme=\"%s\"\n", token, yytext);
  } while (token != T_eof);
  return 0;
}*/
