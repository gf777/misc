#!/bin/bash

FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" bam.ls)
NAME="$(basename -- $FILE)"

bam2fastq ${FILE} -o fastq/${NAME}
