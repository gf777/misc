#! /bin/bash

if [[ -z $1 ]] ; then
        echo "Usage: ./_submit_bowtie2_freebayes.sh <genome> <ref.fasta> <illumina_folder> [job dependency]"
        echo "<ref.fasta> will be linked as asm.fasta."
        exit -1
fi

if ! [ -e asm.fasta ]; then
        ln -s $2 asm.fasta
fi

sample=$1

mkdir -p logs

cpus=2
name=$sample.bowtie2
script=bowtie2.sh
args="$sample $3"
log=$PWD/logs/$name.%A_%a.log

# launch bowtie2 align
if ! [ -e $sample/outs/possorted_bam.bam ]; then
	echo "\
	sbatch --partition=vgl --cpus-per-task=$cpus --job-name=$name --error=$log --output=$log $script $args"
	sbatch --partition=vgl --cpus-per-task=$cpus --job-name=$name --error=$log --output=$log $script $args | awk '{print $4}' > longranger_jid
	wait_for="--dependency=afterok:`cat longranger_jid`"
fi

if ! [ -e aligned.bam 2> /dev/null ]; then	# symlink regardless the actual file exists or not
	ln -s $sample/outs/possorted_bam.bam aligned.bam 2> /dev/null
	ln -s $sample/outs/possorted_bam.bam.bai aligned.bam.bai 2> /dev/null
	ln -s $sample/outs/summary.csv	2> /dev/null
fi

cpus=4
name=$1.freebayes
script=$VGP_PIPELINE/freebayes-polish/freebayes_v1.3.sh
args=$sample
log=logs/$name.%A_%a.log

mkdir -p bcf refdata-asm/fasta/
ln -s ../../asm.fasta refdata-asm/fasta/genome.fa
samtools faidx refdata-asm/fasta/genome.fa

fb_done=`ls bcf/*.done 2> /dev/null | wc -l | awk '{print $1}'`
if ! [[ $fb_done -eq 100 ]]; then
	# Submit job arrays for every 100th contig
	echo "\
	sbatch --partition=vgl --array=1-100 -D $PWD $wait_for --cpus-per-task=$cpus --job-name=$name --error=$log --output=$log $script $args"
	sbatch --partition=vgl --array=1-100 -D $PWD $wait_for --cpus-per-task=$cpus --job-name=$name --error=$log --output=$log $script $args | awk '{print $4}' > freebayes_jid
	wait_for="--dependency=afterok:`cat freebayes_jid`"
fi

cpus=2
name=$sample.consensus
script=$VGP_PIPELINE/freebayes-polish/consensus.sh
args=$sample
walltime=1-0
log=logs/$name.%A_%a.log

echo "\
sbatch --partition=vgl -D $PWD $wait_for --cpus-per-task=$cpus --job-name=$name --time=$walltime --error=$log --output=$log $script $args"
sbatch --partition=vgl -D $PWD $wait_for --cpus-per-task=$cpus --job-name=$name --time=$walltime --error=$log --output=$log $script $args | awk '{print $4}' > consensus_jid
wait_for="--dependency=afterok:`cat consensus_jid`"

if [ -s $sample.qv ]; then
	echo "$sample.qv found. exit."
	exit 0

fi

cpus=4
name=$sample.genomecov
script=$VGP_PIPELINE/qv/genomecov.sh
args=$sample
walltime=1-0
log=logs/$name.%A_%a.log

if ! [ -z $4 ]; then
        wait_for="--dependency=afterok:$3"
fi
echo "\
sbatch --partition=vgl -D $PWD $wait_for --cpus-per-task=$cpus --job-name=$name --time=$walltime --error=$log --output=$log $script $args"
sbatch --partition=vgl -D $PWD $wait_for --cpus-per-task=$cpus --job-name=$name --time=$walltime --error=$log --output=$log $script $args | awk '{print $4}' > genomecov_jid
