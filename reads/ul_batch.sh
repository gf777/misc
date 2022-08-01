#!/bin/bash

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fastq.ls)
NAME="$(basename -- $FILE)"

zcat $FILE | \
awk 'BEGIN {FS = "\t" ; OFS = "\n"} {header = $0 ; getline seq ; getline qheader ; getline qseq ; if (length(seq) >= 100000) {print header, seq, qheader, qseq}}' | \
gzip \
> $NAME
