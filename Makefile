.PHONY: clean distclean default

CC=gcc
CFLAGS=-Wall -ansi -pedantic -g

default: tony clean

parser.h parser.c: parser.y
	bison -dv -o parser.c parser.y

lexer.c: lexer.l
	flex -s -o lexer.c lexer.l

%.o: %.c
	$(CC) $(CFLAGS) -c $<

tony: quads.o lexer.o parser.o symbol.o general.o error.o symbol.o addme.o 
	$(CC) $(CFLAGS) -o tony $^ -lfl

parser.o   : parser.c parser.h symbol.h general.h error.h quads.h
lexer.o    : lexer.c parser.h quads.h
general.o  : general.c general.h error.h
error.o    : error.c general.h error.h
symbol.o   : symbol.c symbol.h general.h error.h parser.h quads.h
quads.o    : quads.c quads.h symbol.h general.h error.h parser.h
addme.o    : addme.c symbol.h

clean:
	$(RM) lexer.c parser.c parser.h parser.output *.o *~

distclean: clean
	$(RM) tony
