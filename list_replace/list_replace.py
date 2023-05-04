import re
import sys

with open(sys.argv[2], 'r') as f:
    d = {line.split(',')[0]: line.split(',')[1].strip('\n') for line in f}

pattern = '|'.join(sorted(re.escape(k) for k in d))

with open(sys.argv[1], 'r') as file:
    new = re.sub(pattern, lambda m: d.get(m.group(0)), file.read())

print(new)