#include "symbol.h"

SymbolEntry * predefines(){

	SymbolEntry *p;

	/* decl puti (int n) */
	p = newFunction("puti");
	forwardFunction(p);
	openScope("puti", 0);
	newParameter("n", typeInteger, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl putb (bool b) */
	p = newFunction("putb");
	forwardFunction(p);
	openScope("putb", 0);
	newParameter("b", typeBoolean, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl putc (char c) */
	p = newFunction("putc");
	forwardFunction(p);
	openScope("putc", 0);
	newParameter("c", typeChar, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl puts (char[] s) */
	p = newFunction("puts");
	forwardFunction(p);
	openScope("puts", 0);
	newParameter("s", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl int geti () */
	p = newFunction("geti");
	forwardFunction(p);
	openScope("geti", 0);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl bool getb () */
	p = newFunction("getb");
	forwardFunction(p);
	openScope("getb", 0);
	endFunctionHeader(p, typeBoolean);
	closeScope();

	/* decl char getc () */
	p = newFunction("getc");
	forwardFunction(p);
	openScope("getc", 0);
	endFunctionHeader(p, typeChar);
	closeScope();

	/* decl gets (int n, char[] s) */
	p = newFunction("gets");
	forwardFunction(p);
	openScope("gets", 0);
	newParameter("n", typeInteger, PASS_BY_REFERENCE, p);
	newParameter("s", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl int abs (int n) */
	p = newFunction("abs");
	forwardFunction(p);
	openScope("abs", 0);
	newParameter("n", typeInteger, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl int ord (char c) */
	p = newFunction("ord");
	forwardFunction(p);
	openScope("ord", 0);
	newParameter("c", typeChar, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl char chr (int n) */
	p = newFunction("chr");
	forwardFunction(p);
	openScope("chr", 0);
	newParameter("n", typeInteger, PASS_BY_VALUE, p);
	endFunctionHeader(p, typeChar);
	closeScope();

	/* decl int strlen (char[] s) */
	p = newFunction("strlen");
	forwardFunction(p);
	openScope("strlen", 0);
	newParameter("s", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl int strcmp (char[] s1, s2) */
	p = newFunction("strcmp");
	forwardFunction(p);
	openScope("strcmp", 0);
	newParameter("s1", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	newParameter("s2", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	endFunctionHeader(p, typeInteger);
	closeScope();

	/* decl strcpy (char[] trg, src) */
	p = newFunction("strcpy");
	forwardFunction(p);
	openScope("strcpy", 0);
	newParameter("trg", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	newParameter("src", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	/* decl strcat (char[] trg, src) */
	p = newFunction("strcat");
	forwardFunction(p);
	openScope("strcat", 0);
	newParameter("trg", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	newParameter("src", typeIArray(typeChar), PASS_BY_REFERENCE, p);
	endFunctionHeader(p, typeVoid);
	closeScope();

	return p;
}
