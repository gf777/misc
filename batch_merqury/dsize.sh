#!/bin/bash

for fasta in */all_p_ctg.fa.gz; do

gunzip -c ${fasta} > ${fasta%.*}

size=$(perl /rugpfs/fs0/vgl/store/gformenti/bin/countFasta.pl ${fasta%.*} | grep "Total length of sequence:" | sed 's/Total length of sequence:\t//g' | sed 's/ bp//g')

echo -e "$(basename $(dirname ${fasta}))\t${size}"

rm ${fasta%.*}

done
