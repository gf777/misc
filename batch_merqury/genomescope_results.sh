#!/bin/bash
while read species; 

do 

het=$(grep "Heterozygosity" $species/genomescope/*/summary.txt | awk '{print $3}')
gsize=$(grep "Genome Haploid Length" $species/genomescope/*/summary.txt | awk '{print $6}' | sed 's/,//g')
gsize_r=$(grep "Genome Repeat Length" $species/genomescope/*/summary.txt | awk '{print $6}' | sed 's/,//g')
gsize_u=$(grep "Genome Unique Length" $species/genomescope/*/summary.txt | awk '{print $6}' | sed 's/,//g')

echo -e "${species}\t${het::-1}\t${gsize}\t${gsize_r}\t${gsize_u}"

done < species.ls