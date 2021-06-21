#!/bin/bash

if [ ! -z ${7} ]; then

arg="-lookup ${7}"

fi

echo "time merfin -hist \
-sequence ${1} \
-seqmers ${2} \
-readmers ${3} \
-peak ${4} \
-output ${5} \
-threads ${6} \
${arg}"

time merfin -hist \
-sequence ${1} \
-seqmers ${2} \
-readmers ${3} \
-peak ${4} \
-output ${5} \
-threads ${6} \
${arg}
