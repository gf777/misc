#!/bin/bash

mkdir -p logs fastq

NFILES=$(cat bam.ls | wc -l)	

sbatch -p vgl --array=1-${NFILES} --cpus-per-task=1 -o logs/slurm-%A_%a.out bam2fastq_batch.sh
