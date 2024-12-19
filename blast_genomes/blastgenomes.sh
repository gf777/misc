#!/bin/bash

set -e

if [ -z $1 ]; then

	echo "use $0 -h for help"
	exit 0
elif [ $1 == "-h" ]; then

	cat << EOF

	Usage: '$0 -a assembly -r reference -o output_prefix'

	blastgenomes.sh is used to test for the presence of any (multi)fasta sequence in a genome assembly.

	Required arguments are:
	-a the genome assembly for the blastdb - can be gzipped
	-r the (multi)fasta file to test - can be gzipped
	-o output folder/prefix

EOF

exit 0

fi

#set options

printf "\n"

while getopts ":a:r:o:" opt; do

	case $opt in
		a)
			ASM=$OPTARG
			echo "Genome assembly for blastdb: -a $OPTARG"
			;;
		r)
			REF=$OPTARG
			echo "Reference mitocontig: -r $OPTARG"
			;;
        o)
        	W_URL=$OPTARG
        	echo "Output prefix: -o $OPTARG"
            ;;
		\?)
			echo "ERROR - Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac

printf "\n"

done

printf "\n"

if ! [[ -e "${W_URL}" ]]; then

	mkdir -p ${W_URL}

fi

if ! [[ -e "${W_URL}/db" ]]; then

	mkdir -p ${W_URL}/db

fi

if [[ ${ASM} =~ \.gz$ ]]; then

	gunzip -c ${ASM} > ${W_URL}/db/${ASM%.*}

else

	cp ${ASM} ${W_URL}/db/${ASM%.*}

fi

makeblastdb -in ${W_URL}/db/${ASM%.*} -parse_seqids -dbtype nucl -out ${W_URL}/db/${ASM%.*}.db

if ! [[ -e "${W_URL}/reference" ]]; then

	mkdir -p ${W_URL}/reference

fi

if [[ ${REF} =~ \.gz$ ]]; then

	gunzip -c ${REF} > ${W_URL}/reference/${REF%.*}

else

	cp ${REF} ${W_URL}/reference/${REF}

fi

#search the sequence using blastn

blastn -outfmt 6 -query ${W_URL}/reference/${REF} -db ${W_URL}/db/${ASM%.*}.db -out ${W_URL}/${ASM%.*.*}_in.out
sed -i "1iquery_acc.ver\tsubject_acc.ver\t%_identity\talignment_length\tmismatches\tgap_opens\tq.start\tq.end\ts.start\ts.end\tevalue\tbitscore" ${W_URL}/${ASM%.*.*}_in.out
cat ${W_URL}/${ASM%.*.*}_in.out | column -t > ${W_URL}/${ASM%.*.*}.out
rm ${W_URL}/${ASM%.*.*}_in.out
