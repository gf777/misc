#!/bin/bash

cd $1

mkdir genomescope

cd genomescope

ln -s ../genomic_data/10x/${1}.meryl.hist ${1}.meryl.hist

k=$2

    echo "
    Rscript $VGP_PIPELINE/meryl2/genomescope.R ${1}.meryl.hist $k 120 ${1}_${k} ${1}_${k} 1
    "
Rscript $VGP_PIPELINE/meryl2/genomescope.R ${1}.meryl.hist $k 120 ${1}_${k} ${1}_${k} 1
