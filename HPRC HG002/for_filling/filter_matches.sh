rm -f alignments_to_exclude.ls excluded_alignments.txt
head -1 alignment.cout > alignment.filtered.cout

awk 'NR>1{p=index($1,":");print substr($1,0,p-1)}' alignment.cout | uniq > scaffold.ls

while read -r scaffold;
do
   
	grep "${scaffold}:" alignment.cout | awk '{print $6}' | sort | uniq > contigs_forpatch.ls
	
	grep -v "${scaffold}:" alignment.cout | grep -wf contigs_forpatch.ls > alignments_to_exclude.ls
	
	cat alignments_to_exclude.ls >> excluded_alignments.txt
	


	awk '{print $6}' alignments_to_exclude.ls | sort | uniq > contigs_to_exclude.ls
	
	grep "${scaffold}:" alignment.cout | grep -vf contigs_to_exclude.ls >> alignment.filtered.cout
   
done < scaffold.ls
