#!/bin/bash
SCRIPT_PATH="../../for_filling"

asm_prefix="${1%.*}"

#chr sizes
samtools faidx $1
cut -f1,2 ${1}.fai > ${1}.sizes

#Extract list of potential gaps to be filled, 
python $SCRIPT_PATH/find_gaps.py $1 > gaps.bed

#ignore gaps of min length
awk -v min_gap="${2}" '{if ($3-$2>min_gap) print $0}' gaps.bed > gaps.gt${2}.bed

#find non-gapped sequence coordinates
bedtools complement -i gaps.gt${2}.bed -g ${1}.sizes > sequences.gaps.gt${2}.bed

#extract non-gapped sequences
bedtools getfasta -fi $1 -bed sequences.gaps.gt${2}.bed > ${asm_prefix}.contigs.gaps.gt${2}.fasta

#extract scaffolds
mkdir -p scaffolds
awk '{ if (substr($0, 1, 1)==">") {filename=(substr($0,2) ".fasta")}; print $0 > "scaffolds/"filename}' $1

#list scaffolds
grep ">" $1 | tr -d ">" > scaffold.ls
