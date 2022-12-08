#!/bin/bash

# for fl in */t1_asm_stats/*_t1.contigs.p.stats; do
# 
# ncontig=$(sed -n '5p' $fl | awk '{print $3}' | sed 's/,//g')
# n50=$(sed -n '5p' $fl | awk '{print $14}' | sed 's/,//g')
# gsize=$(sed -n '5p' $(dirname $fl)/*_t1.gaps.p.stats | awk '{print $2}' | sed 's/,//g')
# gn50=$(sed -n '5p' $(dirname $fl)/*_t1.gaps.p.stats | awk '{print $14}' | sed 's/,//g')
# 
# echo -e "$(basename ${fl})\t${ncontig}\t${n50}\t${gsize}\t${gn50}" >> t1.p_contigs.stats
# 
# done

for fl in */*_s3.fasta.gz; do

mkdir "$(dirname $fl)/s3_stats/"

ln -s "../$(basename ${fl})" "$(dirname $fl)/s3_stats/"

cd "$(dirname $fl)/s3_stats/" 

$VGP_PIPELINE/stats/asm_stats.sh $(basename ${fl}) 1000000000 c

cd ../../

ncontig=$(sed -n '5p' $(dirname $fl)/s3_stats/*_s3.gz.contigs.stats | awk '{print $3}' | sed 's/,//g')
n50=$(sed -n '5p' $(dirname $fl)/s3_stats/*_s3.gz.contigs.stats | awk '{print $14}' | sed 's/,//g')

gsize=$(sed -n '5p' $(dirname $fl)/s3_stats/*_s3.gz.gaps.stats | awk '{print $2}' | sed 's/,//g')
gn50=$(sed -n '5p' $(dirname $fl)/s3_stats/*_s3.gz.gaps.stats | awk '{print $14}' | sed 's/,//g')

echo -e "$(basename ${fl})\t${ncontig}\t${n50}\t${gsize}\t${gn50}" >> s3_contigs.stats

done
