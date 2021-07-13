#!/bin/bash
#set first and second arguments (sequence and base respectively)  
sequence=$1
base=$2
diff_sequence_base=$((${#sequence} - ${#base} | bc))

for ((i=0; i <= ${diff_sequence_base}; i++)); do
       [ ${sequence:i:${#base}} = $base ] && ((count++))

done
if [ $count -gt $3 ]; then
echo $base, $count, $sequence
fi
