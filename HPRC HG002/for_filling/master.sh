#!/bin/bash
SCRIPT_PATH="../../../for_filling"

set -o pipefail

ref=$1
contigs=$2
align_prefix=$3
scaffold_ls=$5
scaffolds=$6

if [ $# -ge 4 ] && [ x$4 != "x" ]; then
   max_gap=$4
else
   max_gap=10000
fi

if [ "x$SLURM_JOB_ID" != "x" ]; then
   threads=$SLURM_CPUS_PER_TASK
elif [ $# -ge 7 ] && [ x$7 != "x" ]; then
   threads=$7
else
   threads=8
fi

printf "Using %s threads.\n" $threads

if [ ! -f $align_prefix.bam ]; then

	minimap2 -a -H -t $threads -x asm20 -I 8G $ref $contigs | samtools view -b -F 4 > $align_prefix.bam
	
fi

if [ ! -f $align_prefix.cout ]; then

	python3 $SCRIPT_PATH/alignment_filter.py --min-len 20000 --min-idy 0.98 --use-all $align_prefix.bam 2> $align_prefix.cerr > $align_prefix.cout

fi

python3 $SCRIPT_PATH/contig_info.py $contigs contig.info

rm -f alignments_to_exclude.ls excluded_alignments.txt
head -1 $align_prefix.cout > $align_prefix.filtered.cout

awk 'NR>1{p=index($1,":");print substr($1,0,p-1)}' $align_prefix.cout | uniq > scaffold.ls

while read -r scaffold;
do
   
	grep "${scaffold}:" $align_prefix.cout | awk '{print $6}' | sort | uniq > contigs_forpatch.ls
	
	grep -v "${scaffold}:" $align_prefix.cout | grep -wf contigs_forpatch.ls > alignments_to_exclude.ls
	
	cat alignments_to_exclude.ls >> excluded_alignments.txt

	awk '{print $6}' alignments_to_exclude.ls | sort | uniq > contigs_to_exclude.ls
	
	grep "${scaffold}:" $align_prefix.cout | grep -vf contigs_to_exclude.ls >> $align_prefix.filtered.cout
   
done < scaffold.ls

mkdir -p patches chrs

while read -r scaffold;
do

	echo "working on scaffold: $scaffold"

	python3 $SCRIPT_PATH/gap_patch.py \
	<(cat <(head -1 contig.info) \
	<(grep "${scaffold}:" contig.info)) \
	<(cat <(head -1 $align_prefix.filtered.cout) \
	<(grep "${scaffold}:" $align_prefix.filtered.cout)) --max-gap $max_gap | \
	#sort according to original scaffolds
	awk '{split($1,a,":");split(a[2],b,"-"); print a[1],b[1],b[2],$0}' | sort -n -k1 -k2 | uniq | cut -d " " -f 5- | \
	#prevent matches with coordinates within 1kb to introduce duplications duplicate
	awk '{split($1,a,":");split(a[2],b,"-");if(!(prev_name==$1 && (prev_start-b[1]<1000 || prev_end-b[1]<1000))){print $0; prev_name=$1; prev_start=b[1]; prev_end=b[2]}}' | \
	#reintroduce gaps
	awk '{split($1,a,":");split(a[2],b,"-");if(prev_name==a[1]){printf "gap\t0\t"b[1]-prev_end"\t.\t0\t+\n"};print $0; prev_name=a[1]; prev_end=b[2]}' \
	> patches/${scaffold}.$align_prefix.patch.bed

	grep -Po "(^.*cont.*?\s|^.*caffold.*?\s|^.*S.*?\s)" patches/${scaffold}.$align_prefix.patch.bed | sort | uniq > patches/${scaffold}.relevant_ref.txt
	seqtk subseq $ref patches/${scaffold}.relevant_ref.txt > patches/${scaffold}.for_patch.fasta
	seqtk subseq $contigs <(grep "${scaffold}:" patches/${scaffold}.relevant_ref.txt) >> patches/${scaffold}.for_patch.fasta
	printf '>gap\n' >> patches/${scaffold}.for_patch.fasta
	printf 'N%.0s' {1..1000000} >> patches/${scaffold}.for_patch.fasta
	printf '\n' >> patches/${scaffold}.for_patch.fasta

	echo ">${scaffold}" > patches/${scaffold}.noformat.fasta
	python3 $SCRIPT_PATH/merge_reads.py patches/${scaffold}.$align_prefix.patch.bed patches/${scaffold}.for_patch.fasta | grep -v ">" | tr -d '\n' >> patches/${scaffold}.noformat.fasta
	fold -c patches/${scaffold}.noformat.fasta > chrs/${scaffold}.fasta

done < scaffold.ls

seqtk subseq $scaffolds <(grep -wvf scaffold.ls $scaffold_ls) > missing_scaffolds.fasta

awk '{ if (substr($0, 1, 1)==">") {filename=(substr($0,2) ".fasta")}; print $0 > "chrs/"filename}' missing_scaffolds.fasta

rm -f gap_filled_scaffolds.fasta missing_scaffolds.fasta

while read -r scaffold;
do

cat chrs/${scaffold}.fasta; echo

done < $scaffold_ls > gap_filled_scaffolds.fasta