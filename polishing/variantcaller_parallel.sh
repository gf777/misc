#!/bin/bash

window=$(sed -n "${3}p" windows.txt)

printf "\
/rugpfs/fs0/vgl/store/gformenti/bin/miniconda3/bin/gcpp aligned_reads.bam -r ${1} -o polished_${1} -o vcf/${1%.*}_${3}.vcf --algorithm arrow -j ${2} -w ${window}\n"
/rugpfs/fs0/vgl/store/gformenti/bin/miniconda3/bin/gcpp aligned_reads.bam -r ${1} -o polished_${1} -o vcf/${1%.*}_${3}.vcf --algorithm arrow -j ${2} -w ${window}


