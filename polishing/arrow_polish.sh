#!/bin/bash

set -e

if [ -z $1 ]; then

	echo "use $0 -h for help"
	exit 0
elif [ $1 == "-h" ]; then

	cat << EOF

	Usage: '$0 -i species_ID -a assembly -b bam_folder -t threads'

	arrow_polish.sh is used to polish a genome assembly generated using long reads.

	Required arguments are:
	-i the species id
	-a the genome assembly .fasta file
	-b the folder where raw data bam files are
	-t the number of threads

EOF

exit 0

fi

#set options

printf "\n"

while getopts ":i:a:b:t:" opt; do

	case $opt in
		i)
			ID=$OPTARG
			echo "Species ID: -i $OPTARG"
			;;
		a)
			ASM=$OPTARG
			echo "Genome assembly: -a $OPTARG"
			;;
        b)
        	BAM=$OPTARG
        	echo "Bam folder: -b $OPTARG"
            ;;
        t)
        	N_PROC=$OPTARG
        	echo "Threads: -t $OPTARG"
            ;;
		\?)
			echo "ERROR - Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac

printf "\n"

done

printf "\n"

if ! [[ -e "${ASM}.mmi" ]]; then

	echo "Generating index."

	pbmm2 index ${ASM} ${ASM}.mmi

	echo "Index ${ASM}.mmi generated."

fi

if ! [[ -e "${ID}_read_set.xml" ]]; then

	echo "Gathering bam files."

	dataset create --type SubreadSet --name ${ID} ${ID}_read_set.xml ${BAM}/*.subreads.bam

	echo "Bam files in ${ID}_read_set.xml"

fi

if ! [[ -e "aligned_reads.bam" ]]; then

	echo "Aligning..."

	pbmm2 align ${ASM}.mmi ${ID}_read_set.xml aligned_reads.bam -j ${N_PROC} --sort -m 5G
	
	echo "Generated aligned_reads.bam file."

fi

if ! [[ -e "aligned_reads.bam.pbi" ]]; then

	echo "Indexing aligned_reads.bam file."

	pbindex aligned_reads.bam

	echo "aligned_reads.bam file indexed."	

fi


if ! [[ -e "${ASM}.fai" ]]; then

	echo "Generating .fai index."	

	samtools faidx ${ASM}

	echo "${ASM}.fai file generated."	

fi

for cutoff in $(seq 5 3 40)
do

	sbatch --partition=vgl --cpus-per-task=32 variantcaller.sh ${ASM} $cutoff ${N_PROC}

done
	
