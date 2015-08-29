#include "symbol.h"

SymbolEntry * predefines(){

	SymbolEntry *p;

	/* decl puti (int n) */
	p = newFunction("puti");
	forwardFunction(p);
	openScope("puti");
	newParameter("n", typeInteger, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl putb (bool b) */
	p = newFunction("putb");
	forwardFunction(p);
	openScope("putb");
	newParameter("b", typeBoolean, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl putc (char c) */
	p = newFunction("putc");
	forwardFunction(p);
	openScope("putc");
	newParameter("c", typeChar, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl puts (char[] s) */
	p = newFunction("puts");
	forwardFunction(p);
	openScope("puts");
	newParameter("s", typeIArray(typeChar), PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl int geti () */
	p = newFunction("geti");
	forwardFunction(p);
	openScope("geti");
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl bool getb () */
	p = newFunction("getb");
	forwardFunction(p);
	openScope("getb");
	endFunctionHeader(p, typeBoolean);
	closeScope();

	/* decl char getc () */
	p = newFunction("getc");
	forwardFunction(p);
	openScope("getc");
	endFunctionHeader(p, typeChar);
	closeScope();

	/* decl gets (int n, char[] s) */
	p = newFunction("gets");
	forwardFunction(p);
	openScope("gets");
	newParameter("n", typeInteger, PASS_BY_VALUE, p);
	newParameter("s", typeIArray(typeChar), PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl int abs (int n) */
	p = newFunction("abs");
	forwardFunction(p);
	openScope("abs");
	newParameter("n", typeInteger, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl int ord (char c) */
	p = newFunction("ord");
	forwardFunction(p);
	openScope("ord");
	newParameter("c", typeChar, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl char chr (int n) */
	p = newFunction("chr");
	forwardFunction(p);
	openScope("chr");
	newParameter("n", typeInteger, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeChar);
	closeScope();

	/* decl int strlen (char[] s) */
	p = newFunction("strlen");
	forwardFunction(p);
	openScope("strlen");
	newParameter("s", typeIArray(typeChar), PASS_BY_VALUE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl int strcmp (char[] s1, s2) */
	p = newFunction("strcmp");
	forwardFunction(p);
	openScope("strcmp");
	newParameter("s1", typeIArray(typeChar), PASS_BY_VALUE, p);
	newParameter("s2", typeIArray(typeChar), PASS_BY_VALUE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl strcpy (char[] trg, src) */
	p = newFunction("strcpy");
	forwardFunction(p);
	openScope("strcpy");
	newParameter("trg", typeIArray(typeChar), PASS_BY_VALUE, p);
	newParameter("src", typeIArray(typeChar), PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl strcat (char[] trg, src) */
	p = newFunction("strcat");
	forwardFunction(p);
	openScope("strcat");
	newParameter("trg", typeIArray(typeChar), PASS_BY_VALUE, p);
	newParameter("src", typeIArray(typeChar), PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();
	
	return p;
}
