#include "tonygc.h"

void allocate ()
{
  word bp = sp;
  subsp(2);
#define code   param(1)
#define result local(1)
#define size   local(2)
  size = SIZE_IN_WORDS(code);
  if (next + size + 1 >= limit_from) {
#define allocate_call_1 (0 << 8 | 1)
    call(gc, allocate_call_1);
    sp++; /* for gc */
    if (next + size + 1 >= limit_from)
      out_of_memory();
  }
  result = (word) next;
  ((word *) result)[0] = code;
  next += size + 1;
  ret(result);
#undef code
#undef result
#undef size
 end:
  sp += 2;
  sp++;
}

void cons ()
{
  word bp = sp;
  subsp(1);
#define head param(2)
#define tail param(1)
#define result local(1)
  push(LIST_OF_VALUES | 2);
  push(&result);
#define cons_call_1 (1 << 8 | 1)
  call(allocate, cons_call_1);
  sp += 2;
  ((word *) result)[1] = head;
  ((word *) result)[2] = (word) tail;
  ret(result);
#undef head
#undef tail
#undef result
 end:
  sp += 1;
  sp++;
}

void head ()
{
  word bp = sp;
#define list param(1)
  ret(((word *) list)[1]);
#undef list
 end:
  sp++;
}

void tail ()
{
  word bp = sp;
#define list param(1)
  ret(((word *) list)[2]);
#undef list
 end:
  sp++;
}

word library_info_table[] = {
  allocate_call_1,                         /* entry 0 */
  /* next */ (word) (library_info_table + 4),
  /* size */ 2 + 0 + 0 + 1,
  /* end */ 0,
  cons_call_1,                             /* entry 4 */ 
  /* next */ 0,
  /* size */ 1 + 0 + 2 + 1,
  /* tail */ ofsparam(1),
  /* end */ 0
};
