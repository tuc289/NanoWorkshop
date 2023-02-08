# Nanopore Workshop 

Nanopore sequencing tutorial workshop for bacterial isolates. In this page, we will go over two parallel process of nanopore sequencing data using i) [GalaxyTrakr](https://galaxytrakr.org/root/login?redirect=%2F)  and ii) [Unix shell](https://en.wikipedia.org/wiki/Unix_shell) command line using same bioinformatics tools

## Table of contents 

* [Getting started](#getting_started)
* [Installation and configuration](#install_and_configure)
* [Workflow](#workflow)
  * [Basecalling and demultiplexing](#basecalling)
  * [Quality Control](#qualitycontrol)
  * [Genome assembly](#genome_assembly)
  * [Genome polishing](#genome_polishing)
  * [Assembled genome assessment](#genome_assessment)
* [Additional process](#Additional)
  * [Hybrid assembly](#hybrid)
* [References and resources](#references)

<a name="getting_started"></a>
## Getting started

<a name="install_and_configure"></a>
## Installation and configuration

### 1. GalaxyTrakr 

<a name="workflow"></a>
## Workflow

<a name="basecalling"></a>
### Basecalling and demultiplexing 

[Performs high accuracy basecalling from FAST5 files](#basecalling) ([**guppy**](https://community.nanoporetech.com/protocols/Guppy-protocol/v/gpb_2003_v1_revaa_14dec2018/linux-guppy))

Basecalling is the process of generating sequence data with its base quality score (.fastq) from the raw signaling results of the Nanopore MinION sequencer. Guppy is the current basecaller provided from Oxford Nanopore. Basecalling can be completed real-time during the sequencing run, however we can also generate high accuracy reads based on the complicated neural network based basecalling from Guppy. Additionally, Guppy can be used to trim the low quality reads and barcode sequences during basecalling

Input files format - *.fast5*
output files format - *.fastq*

before starts, please check if guppy directory is in your PATH varaibles
```
export PATH=$PATH:/directory for guppy installation/bin
echo $PATH #check if ~/ont-guppy-cpu/bin is in the PATH variable
```

Oxford Nanaopore technology provide different type of sequencing library kits, and different flowcells from different technology. It is important to select the same kits/flowcells for basecalling to recognize the right signal. To check the list of the kits and flowcells
```
guppy_basecaller --print_workflows
```
Now you will see something like this
```
Available flowcell + kit combinations are:
flowcell       kit               barcoding config_name                    model version
FLO-PRO001     SQK-LSK109                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-LSK109-XL               dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-LSK110                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-DCS109                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-PCS109                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-PCS110                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-PRC109                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-MLK110-96-XL  included  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-PCB109        included  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO001     SQK-PCB110        included  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO002     SQK-LSK109                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO002     SQK-LSK109-XL               dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
FLO-PRO002     SQK-LSK110                  dna_r9.4.1_450bps_hac_prom     2021-05-05_dna_r9.4.1_promethion_384_dd219f32
```

Find the right combination between flowcells and library preparation kits (here, we are using "SQK-RBK004" and "FLO-MIN106"

```
flowcell       kit               barcoding config_name                    model version
FLO-MIN106     SQK-PBK004        included  dna_r9.4.1_450bps_hac          2021-05-17_dna_r9.4.1_minion_384_d37a2ab9
```

Now, specify the input file, output directory, and configuration name (don't forget to add configuration file extenstion (.cfg) at the end)

**hac** is representing "high accuracy"

```
guppy_basecaller -i [input.fast5] -s [output directory] 
                 -c dna_r9.4.1_450bps_hac.cfg --num_callers 2 --cpu_threads_per_caller 1 --trim_barcodes
```
```
--num_callers : how many parallel basecallers to create
--cpu_threads_per_caller : how many threads will be used per each callers

[num_callers] * [cpu_threads_per_caller] = number of available threads

--trim_barcodes : barcode trimming based on the kit information provided
```

Now, it will generate multiple *.fastq* file from *.fast5* file in our output directory, you can simply combined all the sequences from *.fastq* files into one *.fastq* file
```
cd [output directory]
cat *.fastq > [output file name].fastq
```

Now, one huge *.fastq* file is generated as [output file name].fastq

<a name="qualitycontrol"></a>
### Quality Control

<a name="genome_assembly"></a>
### Genome assembly ([**Flye**](https://github.com/fenderglass/Flye))

Flye is a *de novo* assembler for long read sequencing reads (i.e., PacBio or Oxford Nanopore). It takes raw reads as input and outputs polished contigs. 

If you are using raw nanopore reads directly from the run (fast base balled reads)
```
flye --nano-raw [combined raw reads from previous step].fastq --genome-size 5m -o ./ -t 4
```
If you are using corrected high accuracy reads from Guppy output
```
flye --nano-hq [combined raw reads from previous step].fastq --genome-size 5m -o ./ -t 4
```

<a name="genome_polishing"></a>
### Genome polishing

<a name="genome_assessment"></a>
### Assembled genome assessment

<a name="Additional"></a>
## Additional process

<a name="hybrid"></a>
### Hybrid assembly


<a name="references"></a>
## References and Resources
