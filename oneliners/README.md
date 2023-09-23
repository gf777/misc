Nx plot
`gfastats input.fasta.gz -s c | sort -nrk2 | awk 'BEGIN{pos=0}{total+=$2; size[pos] = $2; cum_size[pos++] = total}END{for (p = 0; p < pos; p++) {print size[p],cum_size[p]/total}}'`