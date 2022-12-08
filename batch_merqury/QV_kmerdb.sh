#!/bin/bash

cd genomic_data/10x/

ls *R1*fastq.gz > R1.fofn
ls *R2*fastq.gz > R2.fofn

sbatch --partition=vgl $tools/meryl/scripts/_submit_meryl2_build_10x.sh 21 R1.fofn R2.fofn ${1} mem=F vgl