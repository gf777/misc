#!/bin/bash

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $1)
NAME="$(basename -- $FILE)"

printf "%s\t%s\n" $NAME $(zcat $FILE | paste - - - - | cut -f2 | wc -c)
