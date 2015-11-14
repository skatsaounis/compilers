CC=gcc
CFLAGS=-g -Wall

driver: driver.c expand.c copygc.c tonygc.h
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^)
