#!/bin/bash

wait_file() {
  local file="$1"; shift

  until [ -f $file ] ; do sleep 300; done
  
}

seed=$RANDOM

mkdir -p exp${3}_rep${4}

if [ ! -f "exp${3}_rep${4}/fw.fastq.gz" ]; then

	seqtk sample -s$seed ${1} ${3} | gzip > exp${3}_rep${4}/fw.fastq.gz

fi

if [ ! -f "exp${3}_rep${4}/rv.fastq.gz" ]; then

	seqtk sample -s$seed ${2} ${3} | gzip > exp${3}_rep${4}/rv.fastq.gz

fi

cd exp${3}_rep${4}

ls *.fastq.gz > input.fofn

if [ ! -f "exp${3}_rep${4}.meryl.hist" ]; then

$VGP_PIPELINE/meryl2/_submit_meryl2_build.sh 21 input.fofn exp${3}_rep${4} vgl

fi

#peak=$(meryl histogram exp${3}_rep${4}.meryl 2>/dev/null | awk '{if($2 > prev){dir="down"}else{dir="up"};if(prev_dir!=dir){counter+=1} prev_dir=dir;prev=$2;if (counter==4){print $1-1; exit}}')

wait_file exp${3}_rep${4}.meryl.hist

Rscript ../../../../../merfin/gs2/genomescope2.0/genomescope.R -i exp${3}_rep${4}.meryl.hist -k 21 -o ../gs2/exp${3}_rep${4} -p 2

peak=$(grep "kmercov" ../gs2/exp${3}_rep${4}/model.txt | tail -n1 | awk '{printf "%.2f", $2*2}')

ln -s ../asm.meryl

#printf "sh ../qv.sh asm.meryl exp${3}_rep${4}.meryl ${peak} 32 > exp${3}_rep${4}.qv\n"
#sh ../qv.sh asm.meryl exp${3}_rep${4}.meryl $peak 32 > exp${3}_rep${4}.qv

if [ ! -f "exp${3}_rep${4}.dump" ]; then

	sh ../merfin_dump.sh ../../../../assemblies/chm13.draft_v1.0.fasta ../../../../assemblies/chm13.draft_v1.0.meryl exp${3}_rep${4}.meryl ${peak} exp${3}_rep${4}.dump 32

fi

if [ ! -f "exp${3}_rep${4}.hist" ]; then

	sh ../merfin_hist.sh ../../../../assemblies/chm13.draft_v1.0.fasta ../../../../assemblies/chm13.draft_v1.0.meryl exp${3}_rep${4}.meryl ${peak} exp${3}_rep${4}.hist 32
fi

