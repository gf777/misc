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

	echo "Generating fasta index."

	pbmm2 index ${ASM} ${ASM}.mmi

	echo "Index ${ASM}.mmi generated."

fi

for bam in ${BAM}/*.subreads.bam; do
if ! [[ -e "$bam.pbi" ]]; then

	echo "Generating bam index."

	pbindex $bam

	echo "Index $bam.pbi generated."

fi
done

if ! [[ -e "${ID}_read_set.xml" ]]; then

	echo "Gathering bam files."

	dataset create --type SubreadSet --name ${ID} ${ID}_read_set.xml ${BAM}/*.subreads.bam

	echo "Bam files in ${ID}_read_set.xml"

fi

if ! [[ -e "aligned_reads.bam" ]]; then

	echo "Aligning..."

	pbmm2 align ${ASM}.mmi ${ID}_read_set.xml aligned_reads.bam -j ${N_PROC} --sort -m 10G

	echo "Generated aligned_reads.bam file."

fi

if ! [[ -e "aligned_reads.bam.pbi" ]]; then

	echo "Indexing aligned_reads.bam file."

	pbindex aligned_reads.bam

	echo "aligned_reads.bam file indexed (pbi)."	

fi

if ! [[ -e "aligned_reads.bam.bai" ]]; then

	echo "Indexing aligned_reads.bam file."

	samtools index aligned_reads.bam -@ ${N_PROC} 

	echo "aligned_reads.bam file indexed (bai)."	

fi

if ! [[ -e "${ASM}.fai" ]]; then

	echo "Generating .fai index."	

	samtools faidx ${ASM}

	echo "${ASM}.fai file generated."	

fi

scaffN=$(wc -l ${ASM}.fai | awk '{print $1}')
gsize=$(awk '{sum+=$2}END{print sum}' ${ASM}.fai)
njobs=20
max=$(( (${gsize} + (${njobs} - 1)) / ${njobs} )) #round up
total=0
counter=0
lineN=0
partial_sum=0

printf "gsize=${gsize}\nnjobs=${njobs}\nmax=${max}\n"

printf "header\tcurrent size\ttotal\tmax\n"

mkdir -p logs vcf

rm -f windows.txt

while IFS=$'\t' read -r -a cols
do

    lineN=$(( lineN+1 ))
    partial_sum=$(( partial_sum+${cols[1]} ))
    
    printf "${cols[0]}\t${cols[1]}\t${partial_sum}\t${max}\n"
    
    if [[ ! -z $windows ]] && ([[ $partial_sum -gt $max ]] || [[ $lineN -eq $scaffN ]] || [[ ${#windows} -gt 100000  ]]); then
    
        counter=$(( counter+1 ))
        log=logs/${ASM%.*}_${counter}.out
        
        if [[ $lineN -eq $scaffN ]]; then #account for the final scaffold
        
            windows="${windows}${cols[0]}:0-${cols[1]},"
        
        fi
        
        printf "${windows::${#windows}-1}\n" >> windows.txt
    
        printf "\
sbatch --partition=vgl --cpus-per-task=${N_PROC} --nice=10000 --error=$log --output=$log variantcaller_parallel.sh ${ASM} ${N_PROC} ${counter}\n"
       sbatch --partition=vgl --cpus-per-task=${N_PROC} --nice=10000 --error=$log --output=$log variantcaller_parallel.sh ${ASM} ${N_PROC} ${counter}
 
        windows=""
        partial_sum=${cols[1]}
 
    fi
    
    windows="${windows}${cols[0]}:0-${cols[1]},"
 
done < ${ASM}.fai



