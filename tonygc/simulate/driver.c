#include <stdio.h>
#include <stdlib.h>

#include "tonygc.h"

#define LIVENESS

#ifdef LIVENESS
#define NOT_LIVE(x) 0
#else
#define NOT_LIVE(x) x
#endif

#define MAX 3000

word space1[MAX], space2[MAX];

word *space_from = space1;
word *limit_from = space1 + MAX;
word *space_to = space2;
word *limit_to = space2 + MAX;
word *next = space1;

#define MAX_STACK 5000
word stack[MAX_STACK];
word sp = MAX_STACK - 1;

void out_of_memory ()
{
  fprintf(stderr, "Out of memory!\n");
  exit(1);
}

void stack_underflow ()
{
  fprintf(stderr, "Stack underflow!\n");
  exit(1);
}

void internal_error ()
{
  fprintf(stderr, "Internal error (invalid GC info)!\n");
  exit(1);
}

void make_list ()
{
  word bp = sp;
  subsp(2);
#define size   param(1)
#define result local(1)
  result = nil;
#define i      local(2)
  for (i = 1; i <= size; i++) {
    push(false);
    push(i);
    push(result);
    push(&result);
#define make_list_call_1 ((2 << 8) | 1)
    call(cons, make_list_call_1);
    sp += 4;
  }
  ret(result);
#undef size
#undef result
#undef i
 end:
  sp += 2;
  sp++;
}

word make_list_info_table[] = {
  make_list_call_1,                            /* entry 0 */ 
  /* next */ library_info_table,
  /* size */ 2 + 0 + 4 + 1,
  /* result */ NOT_LIVE(ofslocal(1)),
  /* end */ 0
};

void print_list ()
{
  word bp = sp;
  subsp(1);
#define l param(1)
#define temp local(1)
  while ((word *) l != nil) {
    push(l);
    push(&temp);
#define print_list_call_1 ((3 << 8) | 1)
    call(head, print_list_call_1);
    sp += 2;
    printf("%d ", temp);
    push(l);
    push(&l);
#define print_list_call_2 ((3 << 8) | 2)
    call(tail, print_list_call_2);
    sp += 2;
  }
  printf("end\n");
#undef l
#undef temp
 end:
  sp += 1;
  sp++;
}

word print_list_info_table[] = {
  print_list_call_1,                           /* entry 0 */ 
  /* next */ print_list_info_table + 5,
  /* size */ 1 + 0 + 2 + 1,
  /* l */ ofsparam(1),
  /* end */ 0,
  print_list_call_2,                           /* entry 5 */ 
  /* next */ make_list_info_table,
  /* size */ 1 + 0 + 2 + 1,
  /* l */ NOT_LIVE(ofsparam(1)),
  /* end */ 0
};

void check_lists ()
{
  word bp = sp;
  subsp(2);
#define n param(3)
#define l param(2)
#define r param(1)
#define i local(1)
#define temp local(2)
  i = 1;
  while (i <= n) {
    if (r == nil)
      ret(false);
    push(r);
    push(&temp);
#define check_lists_call_1 ((4 << 8) | 1)
    call(head, check_lists_call_1);
    sp += 2;
    if (temp != i)
      ret(false);
    i++;
    push(r);
    push(&r);
#define check_lists_call_2 ((4 << 8) | 2)
    call(tail, check_lists_call_2);
    sp += 2;
  }
  i = n;
  while (i >= 1) {
    if (l == nil)
      ret(false);
    push(l);
    push(&temp);
#define check_lists_call_3 ((4 << 8) | 3)
    call(head, check_lists_call_3);
    sp += 2;
    if (temp != i)
      ret(false);
    i--;
    push(l);
    push(&l);
#define check_lists_call_4 ((4 << 8) | 4)
    call(tail, check_lists_call_4);
    sp += 2;
  }
  ret(true);
#undef n
#undef l
#undef r
#undef i
#undef temp
 end:
  sp += 2;
  sp++;
}

word check_lists_info_table[] = {
  check_lists_call_1,                          /* entry 0 */ 
  /* next */ check_lists_info_table + 6,
  /* size */ 2 + 0 + 2 + 1,
  /* l */ ofsparam(2),
  /* r */ ofsparam(1),
  /* end */ 0,
  check_lists_call_2,                          /* entry 6 */ 
  /* next */ check_lists_info_table + 12,
  /* size */ 2 + 0 + 2 + 1,
  /* l */ ofsparam(2),
  /* r */ NOT_LIVE(ofsparam(1)),
  /* end */ 0,
  check_lists_call_3,                          /* entry 12 */ 
  /* next */ check_lists_info_table + 18,
  /* size */ 2 + 0 + 2 + 1,
  /* l */ ofsparam(2),
  /* r */ ofsparam(1),
  /* end */ 0,
  check_lists_call_4,                          /* entry 18 */ 
  /* next */ print_list_info_table,
  /* size */ 2 + 0 + 2 + 1,
  /* r */ ofsparam(1),
  /* l */ NOT_LIVE(ofsparam(2)),
  /* end */ 0
};

void revert_tailrec ()
{
  word bp = sp;
  subsp(2);
#define l param(2)
#define r param(1)
#define temp1 local(1)
  temp1 = nil;
#define temp2 local(2)
  if (l == nil)
    ret(r);
  else {
    push(l);
    push(&temp1);
#define revert_tailrec_call_1 ((5 << 8) | 1)
    call(tail, revert_tailrec_call_1);
    sp += 2;
    push(temp1);
    push(false);
    push(l);
    push(&temp2);
#define revert_tailrec_call_2 ((5 << 8) | 2)
    call(head, revert_tailrec_call_2);
    sp += 2;
    push(temp2);
    push(r);
    push(&temp1);
#define revert_tailrec_call_3 ((5 << 8) | 3)
    call(cons, revert_tailrec_call_3);
    sp += 4;
    push(temp1);
    push(&temp1);
#define revert_tailrec_call_4 ((5 << 8) | 4)
    call(revert_tailrec, revert_tailrec_call_4);
    sp += 3;
    ret(temp1);
  }
#undef l
#undef r
#undef temp1
#undef temp2
 end:
  sp += 2;
  sp++;
}

word revert_tailrec_info_table[] = {
  revert_tailrec_call_1,                       /* entry 0 */ 
  /* next */ revert_tailrec_info_table + 7,
  /* size */ 2 + 0 + 2 + 1,
  /* l */ ofsparam(2),
  /* r */ ofsparam(1),
  /* temp1 */ NOT_LIVE(ofslocal(1)),
  /* end */ 0,
  revert_tailrec_call_2,                       /* entry 7 */ 
  /* next */ revert_tailrec_info_table + 15,
  /* size */ 2 + 2 + 2 + 1,
  /* r */ ofsparam(1),
  /* extra: temp1 */ ofslocal(3),
  /* l */ NOT_LIVE(ofsparam(2)),
  /* temp1 */ NOT_LIVE(ofslocal(1)),
  /* end */ 0,
  revert_tailrec_call_3,                       /* entry 15 */ 
  /* next */ revert_tailrec_info_table + 23,
  /* size */ 2 + 1 + 4 + 1,
  /* extra: temp1 */ ofslocal(3),
  /* l */ NOT_LIVE(ofsparam(2)),
  /* r */ NOT_LIVE(ofsparam(1)),
  /* temp1 */ NOT_LIVE(ofslocal(1)),
  /* end */ 0,
  revert_tailrec_call_4,                       /* entry 23 */ 
  /* next */ check_lists_info_table,
  /* size */ 2 + 0 + 3 + 1,
  /* l */ NOT_LIVE(ofsparam(2)),
  /* r */ NOT_LIVE(ofsparam(1)),
  /* temp1 */ NOT_LIVE(ofslocal(1)),
  /* end */ 0
};

void revert_list ()
{
  word bp = sp;
  subsp(1);
#define l param(1)
#define temp local(1)
  temp = nil;
  push(l);
  push(nil);
  push(&temp);
#define revert_list_call_1 ((6 << 8) | 1)
  call(revert_tailrec, revert_list_call_1);
  sp += 3;
  ret(temp);
#undef l
#undef temp
 end:
  sp += 1;
  sp++;
}

word revert_list_info_table[] = {
  revert_list_call_1,                          /* entry 0 */ 
  /* next */ revert_tailrec_info_table,
  /* size */ 1 + 0 + 3 + 1,
  /* l */ NOT_LIVE(ofsparam(1)),
  /* temp */ NOT_LIVE(ofslocal(1)),
  /* end */ 0
};

int main ()
{
  word bp;
  push(ret_of_main);
  bp = sp;
  subsp(4);
#define l local(1)
  l = nil;
#define r local(2)
  r = nil;
#define i local(3)
#define temp local(4)

  printf("START\tused: %d, available: %d\n",
         next-space_from, limit_from-next);
  for (i=1; i<2000; i++) {
    push(i);
    push(&l);
#define main_call_1 ((99 << 8) | 1)
    call(make_list, main_call_1);
    sp += 2;
    if (i < 10 || i == 53) {
      push(l);
      push(nil);
#define main_call_2 ((99 << 8) | 2)
      call(print_list, main_call_2);
      sp += 2;
    }
    printf("DSC(%d)\tused: %d, available: %d\n", i,
           next-space_from, limit_from-next);
    push(l);
    push(&r);
#define main_call_3 ((99 << 8) | 3)
    call(revert_list, main_call_3);
    sp += 2;
    if (i < 10 || i == 53) {
      push(r);
      push(nil);
#define main_call_4 ((99 << 8) | 4)
      call(print_list, main_call_4);
      sp += 2;
    }
    push(i);
    push(l);
    push(r);
    push(&temp);
#define main_call_5 ((99 << 8) | 5)
    call(check_lists, main_call_5);
    sp += 4;
    if (!temp)
      printf("WRONG!\n");
    printf("ASC(%d)\tused: %d, available: %d\n", i,
           next-space_from, limit_from-next);
  }  

 end:
  sp += 4;
  return 0;
}

word frame_info_table[] = {
  main_call_1,                                 /* entry 0 */ 
  /* next */ frame_info_table + 6,
  /* size */ 4 + 0 + 2 + 1,
  /* l */ NOT_LIVE(ofslocal(1)),
  /* r */ NOT_LIVE(ofslocal(2)),
  /* end */ 0,
  main_call_2,                                 /* entry 6 */
  /* next */ frame_info_table + 12,
  /* size */ 4 + 0 + 2 + 1,
  /* l */ ofslocal(1),
  /* r */ NOT_LIVE(ofslocal(2)),
  /* end */ 0,
  main_call_3,                                 /* entry 12 */
  /* next */ frame_info_table + 18,
  /* size */ 4 + 0 + 2 + 1,
  /* l */ ofslocal(1),
  /* r */ NOT_LIVE(ofslocal(2)),
  /* end */ 0,
  main_call_4,                                 /* entry 18 */
  /* next */ frame_info_table + 24,
  /* size */ 4 + 0 + 2 + 1,
  /* l */ ofslocal(1),
  /* r */ ofslocal(2),
  /* end */ 0,
  main_call_5,                                 /* entry 24 */
  /* next */ revert_list_info_table,
  /* size */ 4 + 0 + 4 + 1,
  /* l */ NOT_LIVE(ofslocal(1)),
  /* r */ NOT_LIVE(ofslocal(2)),
  /* end */ 0
};

word ret_of_main = 0xABBA;
