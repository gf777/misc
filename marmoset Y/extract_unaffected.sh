#!/bin/bash

rm -f all_unaffected.fasta

for scaffold in *.1; do

if ! [[ -e $scaffold/$scaffold.collapse/sda.asm.bam ]]; then

cat $scaffold/$scaffold.fasta >> all_unaffected.fasta

else

	printf "%s: sequence decollapsed. skipping.\n" $scaffold

fi

done
