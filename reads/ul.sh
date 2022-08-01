#!/bin/bash

mkdir -p logs

NFILES=$(cat fastq.ls | wc -l)	

sbatch -p vgl --array=1-${NFILES} --cpus-per-task=8 -o logs/slurm-%A_%a.out ul_batch.sh
