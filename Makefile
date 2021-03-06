.PHONY: clean distclean default

CC=gcc
CFLAGS=-Wall -ansi -pedantic -g

default: tonyc clean

parser.h parser.c: parser.y
	bison -dv -o parser.c parser.y

lexer.c: lexer.l
	flex -s -D_POSIX_SOURCE -o lexer.c lexer.l

%.o: %.c
	$(CC) $(CFLAGS) -c $<

tonyc: quads.o lexer.o parser.o symbol.o general.o error.o symbol.o addme.o generator.o
	$(CC) $(CFLAGS) -o tonyc $^ -lfl

parser.o    : parser.c parser.h symbol.h general.h error.h quads.h generator.h
lexer.o     : lexer.c parser.h quads.h
general.o   : general.c general.h error.h
error.o     : error.c general.h error.h
symbol.o    : symbol.c symbol.h general.h error.h parser.h quads.h
quads.o     : quads.c quads.h symbol.h general.h error.h parser.h
addme.o     : addme.c symbol.h
generator.o : generator.c generator.h quads.h symbol.h general.h

clean:
	$(RM) lexer.c parser.c parser.h parser.output *.o *~

distclean: clean
	$(RM) tonyc
