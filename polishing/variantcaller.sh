#!/bin/bash

mkdir cutoff_${2}

cd cutoff_${2}

ln -s ../aligned_reads.bam
ln -s ../aligned_reads.bam.pbi
ln -s ../${1}
ln -s ../${1}.fai

variantCaller aligned_reads.bam -r ${1} -o polished_${1} --algorithm arrow --numWorkers ${3} --minCoverage ${2}

ln -s /vggpfs/fs3/vgl/scratch/gformenti/blue_whale/genomic_data/10x/mBalMus1.k21.meryl/

$tools/merqury/_submit_merqury.sh mBalMus1.k21.meryl/ polished_${1} merqury_${2}
