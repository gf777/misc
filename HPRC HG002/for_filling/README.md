Instructions to run gap patching.

First, prepare your assembly files for patching:
```
prepare_asm.sh scaffolded_asm.fasta min_gap_size
```
This will generate several outputs useful for the patching process, including chromsome sizes, a bed list of gaps to be filled (potentially filtered by size), the contigs based on the filtered gaps, and the original scaffolds.

Second, run the script for gap patching:
```
master.sh nanopore_asm.fasta contigs.fasta out_prefix max_gap_size original_scaffold_ls scaffolded_asm.fasta <n_threads>
```
Where the `nanopore_asm.fasta` is an assembly generated using ultralong ONT data, `contigs.fasta` are the contigs generated from `prepare_asm.sh` and you also provide the list of the original scaffold and the scaffolds themeselves. You should also set a maximux size for the gaps to be filled if your input has sized gaps.
