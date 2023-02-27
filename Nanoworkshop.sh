#!/bin/bash
## Usage : Nanoworkshop.sh <directory to all individual fastq files>


## change directory to all individual fastq files and concatenate all individual fastq files
cd $1
cat *.fastq > reads.fastq

## Running Nanoplot for reads quality check
NanoPlot --fastq reads.fastq --minlength 150 --outdir Nanoplot_results --tsv_stats

## Genome assembly and polishing
flye --nano-raw reads.fastq -o Flye_output -t 8 -i 1
medaka-consensus -i reads.fastq -d Flye_output/assembly.fasta -m r941_min_fast_g303 -t 8 -o medaka_results

## Quast for assembly assessment
quast -i medaka_results/consensus.fasta --nanopore reads.fastq --min-contig 500 --outdir quast_results

## AMR gene identification
abricate --db ncbi medaka_results/consensus.fasta > abricate_amr.tab

## Virulence gene identification
abricate --db vfdb medaka_results/consensus.fasta > abricate_vf.tab

## Running MLST 
mlst medaka_results/consensus.fasta > mlst_result

## in silico serotyping using SeqSero2
SeqSero2_package.py -p 4 -t 4 -m k -i medaka_results/consensus.fasta 

