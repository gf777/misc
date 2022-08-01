#!/bin/bash

mkdir -p logs_coverage

NFILES=$(cat $1 | wc -l)	

sbatch -p vgl --array=1-${NFILES} --cpus-per-task=8 -o logs_coverage/slurm-%A_%a.out coverage_batch.sh $1
