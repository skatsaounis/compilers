#ifndef __TONYGC_H__
#define __TONYGC_H__

typedef enum { false=0, true=1 } bool;
typedef unsigned char byte;
typedef unsigned int word;

extern word *space_from, *space_to;
extern word *limit_from, *limit_to;
extern word *next;

#define MASK_TYPE            (3U << (8*sizeof(word)-2))
#define LIST_OF_POINTERS     (3U << (8*sizeof(word)-2))
#define LIST_OF_VALUES       (2U << (8*sizeof(word)-2))
#define ARRAY_OF_POINTERS    (1U << (8*sizeof(word)-2))
#define ARRAY_OF_VALUES      (0U << (8*sizeof(word)-2))
#define SIZE_IN_WORDS(w)     ((w) & (~MASK_TYPE))

#define nil                  ((word *) 0)

void gc ();

void internal_error();
void out_of_memory();

extern word stack[];
extern word sp;

extern word ret_of_main;
extern word frame_info_table[];

#define ofsparam(n) ((n)+1)
#define ofslocal(n) (-(n))
#define param(n)    (stack[bp+ofsparam(n)])
#define local(n)    (stack[bp+ofslocal(n)])

#define push(x)      do { if (sp <= 0) stack_underflow(); \
                          stack[--sp] = (word) (x); } while(0)
#define subsp(x)     do { if (sp < x) stack_underflow(); \
                          sp -= x; } while(0)
#define call(f, u)   do { push(u); f(); } while(0)
#define ret(x)       do { *((word *)(stack[bp+1])) = x; goto end; } while(0)

void cons ();
void init_array ();
void head ();
void tail ();

extern word library_info_table[];

#endif
