#include "tonygc.h"

#define POINTS_TO_FROM_SPACE(p) (space_from <= (p) && (p) < limit_from)
#define FORWARDED               (LIST_OF_POINTERS | 0x0BAD)

word *forward (word *p)
{
  if (POINTS_TO_FROM_SPACE(p)) {
    if (p[0] == FORWARDED)
      return (word *) (p[1]);
    else {
      int i;
      for (i = 0; i <= SIZE_IN_WORDS(p[0]); i++)
        next[i] = p[i];
      p[1] = (word) next;
      next += SIZE_IN_WORDS(p[0]) + 1;
      p[0] = FORWARDED;
      return (word *) p[1];
    }
  }
  else
    return p;
}

void gc ()
{
  word *scan, *temp;
  int i, bp;

  scan = next = space_to;
  /* traverse root set */
  bp = sp;
  while (stack[bp] != ret_of_main) {
    word *l = frame_info_table;
    while (l[0] != stack[bp]) {
      l = (word *) l[1];
      if (l == 0)
        internal_error();
    }
    bp += l[2];
    for (i=3; l[i] != 0; i++)
      stack[bp + l[i]] = (word) forward((word *) stack[bp + l[i]]);
  }
  /* traverse forwarded space */
  while (scan < next) {
    switch (scan[0] & MASK_TYPE) {
    case LIST_OF_POINTERS:
      scan[1] = (word) forward((word *) scan[1]);
      /* continue to next */
    case LIST_OF_VALUES:
      scan[2] = (word) forward((word *) scan[2]);
      scan += 2 + 1;
      break;
    case ARRAY_OF_POINTERS:
      for (i = 1; i <= SIZE_IN_WORDS(scan[0]); i++)
        scan[i] = (word) forward((word *) scan[i]);
      /* continue to next */
    case ARRAY_OF_VALUES:
      scan += SIZE_IN_WORDS(scan[0]) + 1;
      break;
    }
  }
  /* swap to/from spaces */
  temp = space_from; space_from = space_to; space_to = temp;
  temp = limit_from; limit_from = limit_to; limit_to = temp;

}
