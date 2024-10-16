# Plot hic insert size distribution

```
grep IS bam.stats | grep -v "0\t0\t0\t0" | cut -f2,4 | grep -v "\t0" > insert.sizes

```
