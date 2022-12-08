#!/bin/bash

for fasta in */*_q2*fasta.gz; do

gunzip -c ${fasta} > ${fasta%.*}

size=$(perl /rugpfs/fs0/vgl/store/gformenti/bin/countFasta.pl ${fasta%.*} | grep "Total length of sequence:" | sed 's/Total length of sequence:\t//g' | sed 's/ bp//g')

echo -e "$(basename ${fasta})\t${size}"

rm ${fasta%.*}

done