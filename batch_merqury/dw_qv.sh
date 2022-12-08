#!/bin/bash

aws s3 cp --exclude "*" --recursive --include "assembly_vgp_standard*/intermediates/falcon_unzip/unzip_stage_3/all_p_ctg.fa.gz" s3://genomeark/species/${1}/${2}/ ${2}

mv ${2}/assembly_vgp_standard*/intermediates/falcon_unzip/unzip_stage_3/all_p_ctg.fa.gz ${2}

rm -r ${2}/assembly_vgp_standard*/

aws s3 cp --exclude "*" --recursive --include "assembly_vgp_standard*/intermediates/falcon_unzip/unzip_stage_3/all_h_ctg.fa.gz" s3://genomeark/species/${1}/${2}/ ${2}

mv ${2}/assembly_vgp_standard*/intermediates/falcon_unzip/unzip_stage_3/all_h_ctg.fa.gz ${2}

rm -r ${2}/assembly_vgp_standard*/

cd ${2}

mkdir p_h_ctg

cd p_h_ctg 

ln -s ../all_p_ctg.fa.gz ${2}_p_ctg.fa.gz
ln -s ../all_p_ctg.fa.gz ${2}_h_ctg.fa.gz
ln -s ../genomic_data/10x/${2}.meryl ${2}.meryl

$tools/merqury/_submit_merqury.sh ${2}.meryl ${2}_p_ctg.fa.gz ${2}_h_ctg.fa.gz p_h_ctg
