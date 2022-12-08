#!/bin/bash

mkdir ${2}

cd ${2}

sbatch --partition=vgl aws s3 cp --recursive --exclude "*" --include "assembly_vgp_standard*/intermediates/${2}_*.fasta.gz" s3://genomeark/species/${1}/${2}/ .

sbatch --partition=vgl aws s3 cp --recursive --exclude "*" --include "assembly_cambridge/intermediates/${2}_*.fasta.gz" s3://genomeark/species/${1}/${2}/ .

sbatch --partition=vgl aws s3 cp s3://genomeark/species/${1}/${2}/intermediates/falcon_unzip/unzip_stage_3/all_p_ctg.fa.gz .

sbatch --partition=vgl aws s3 cp s3://genomeark/species/${1}/${2}/intermediates/falcon_unzip/unzip_stage_3/all_h_ctg.fa.gz .

sbatch --partition=vgl aws s3 cp --recursive --exclude "*_I1_*" s3://genomeark/species/${1}/${2}/genomic_data/10x/ genomic_data/10x/ | awk '{print $4}' > 2.id

sbatch --partition=vgl --dependency="afterok:$(cat 2.id)" ../QV_kmerdb.sh ${2}

sbatch --partition=vgl aws s3 cp --recursive --exclude "*" --include "assembly_vgp_standard*/${2}.*.*.fasta.gz" s3://genomeark/species/${1}/${2}/ .

sbatch --partition=vgl aws s3 cp --recursive --exclude "*" --include "assembly_cambridge/${2}.*.*.fasta.gz" s3://genomeark/species/${1}/${2}/ .

if ! [[ -f genomic_data/10x/${2}.meryl.hist ]]; then

sbatch --partition=vgl aws s3 cp --recursive --exclude "*" --include "${2}.*.fasta.gz" s3://genomeark/species/${1}/${2}/assembly_curated/ .

fi

wait_file() {
  local file="$1"; shift

  until [ -f $file ] ; do sleep 300; done
  
}

wait_file genomic_data/10x/${2}.meryl.hist

mv assembly_vgp_standard*/intermediates/* .
mv assembly_vgp_standard*/* .

mv assembly_cambridge/intermediates/* .
mv assembly_cambridge/* 

rm -r assembly_vgp_standard*/ assembly_cambridge

fileA=("c1" "p1" "t1" "t2" "pri.asm" "pri.cur")
fileB=("c2" "q2" "t1" "t2" "alt.asm" "alt.cur")

for (( n=0; n<${#fileA[@]}; n++ ))
do
	
	if [[ ${fileA[$n]} == "t1" || ${fileA[$n]} == "t2"  ]]; then
		
		mkdir ${fileA[$n]}_asm_stats
		gunzip ${2}_${fileA[$n]}.fasta.gz
		sed -i '/^>/ s/|/_/g' ${2}_${fileA[$n]}.fasta
		ln -s ../${2}_${fileA[$n]}.fasta ${fileA[$n]}_asm_stats
		
		cd ${fileA[$n]}_asm_stats
		
		$VGP_PIPELINE/stats/asm_stats.sh ${2}_${fileA[$n]}.fasta 1000000000 p
		
		cd ..
		
		mkdir ${fileA[$n]}
		
		ln -s ../${fileA[$n]}_asm_stats/${2}_${fileA[$n]}.p.fasta ${fileA[$n]}
		ln -s ../${fileA[$n]}_asm_stats/${2}_${fileA[$n]}.h.fasta ${fileA[$n]}
		ln -s ../genomic_data/10x/${2}.meryl ${fileA[$n]}
		
		cd ${fileA[$n]}
		
		sbatch --partition=vgl $tools/merqury/_submit_merqury.sh ${2}.meryl ${2}_${fileA[$n]}.p.fasta ${2}_${fileB[$n]}.h.fasta ${2}_${fileA[$n]}_p_${fileB[$n]}_h
		
		cd ..
		
	else
	
		mkdir ${fileA[$n]}_${fileB[$n]}
		
		if [[ ${fileA[$n]} == "pri.asm" ]]; then
		
			pri=$(ls *pri.asm*gz | head -1)
			alt=$(ls *alt.asm*gz | head -1)
			
		elif [[ ${fileA[$n]} == "pri.cur" ]]; then
		
			pri=$(ls *pri.cur*gz | head -1)
			alt=$(ls *alt.cur*gz | head -1)
			
		else
				
			pri=${2}_${fileA[$n]}.fasta.gz
			alt=${2}_${fileB[$n]}.fasta.gz	
		
		fi
		
		ln -s ../${pri} ${fileA[$n]}_${fileB[$n]}/
		ln -s ../${alt} ${fileA[$n]}_${fileB[$n]}/
		ln -s ../genomic_data/10x/${2}.meryl ${fileA[$n]}_${fileB[$n]}/
		
		cd ${fileA[$n]}_${fileB[$n]}

		sbatch --partition=vgl $tools/merqury/_submit_merqury.sh ${2}.meryl ${pri} ${alt} ${2}_${fileA[$n]}_${fileB[$n]}
    
    	cd ..
	
	fi
	   
done