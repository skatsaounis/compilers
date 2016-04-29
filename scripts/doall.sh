#!/bin/bash

MYLANG=tony

start="$1"

for f in Correct/test[0-9]*.$MYLANG Wrong/test[0-9]*.$MYLANG ; do
  t=${f/%.$MYLANG}
  if [[ "$t" < "$start" ]]; then
    continue
  fi
  ./do.sh $t
done

exit 0
