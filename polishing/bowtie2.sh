#!/bin/bash

if [ -z $1 ] ; then
	echo "Usage: ./bowtie2.sh <genome_id> <data>"
	echo "Assumes we have asm.fasta"
	exit -1
fi

sample=$1
echo $sample
data=$2
echo $data
ref=asm.fasta
ref=${ref/.fasta/}      ## if contains .fasta, remove it

mkdir -p $sample/outs/

echo "=== start indexing reference ==="
echo "\
bowtie2-build $ref.fasta $ref"
bowtie2-build $ref.fasta $ref
echo ""

echo "=== start running bowtie2 ==="
bowtie2 -x $ref -1 $data/*R1*.fastq.gz -2 $data/*R2*.fastq.gz -p 32 | samtools sort -O BAM -o $sample/outs/possorted_bam.bam

samtools index $sample/outs/possorted_bam.bam -@ 32

mean_cov=$(samtools depth -a $sample/outs/possorted_bam.bam | awk '{sum+=$3} END {OFMT="%f"; print sum/NR}')

printf ",,,,,,,,,,,,,,,,%s\n" $mean_cov > $sample/outs/summary.csv

