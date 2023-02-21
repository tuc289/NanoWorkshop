# Nanopore whole genome sequence analyses workshop 

This tutorial provides an overview of analyses of bacterial whole-genome sequences produced using a Nanopore sequencer. The tutorial shows the process of applying the same bioinformatics tools for Nanopore sequence analyses using i) [GalaxyTrakr](https://galaxytrakr.org/root/login?redirect=%2F) and ii) [Unix shell](https://en.wikipedia.org/wiki/Unix_shell) command line.

## Table of contents 

* [Getting started](#getting_started)
* [Installation and configuration](#install_and_configure)
* [Workflow](#workflow)
  * [Basecalling and demultiplexing](#basecalling)
  * [Quality Control](#qualitycontrol)
  * [Genome assembly](#genome_assembly)
  * [Genome polishing](#genome_polishing)
  * [Assembled genome quality assessment](#genome_assessment)
* [Additional analyses](#Additional)
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

[Perform high accuracy basecalling from FAST5 files](#basecalling) ([**guppy**](https://community.nanoporetech.com/protocols/Guppy-protocol/v/gpb_2003_v1_revaa_14dec2018/linux-guppy))

Basecalling is the process of generating sequence data with base quality scores (.fastq) from the raw sequencing signal produced by the Nanopore MinION sequencer. In this workflow, we will use Guppy - the basecaller provided by the Oxford Nanopore Technologies (ONT). Guppy can also be used to trim the low quality reads and sequence barcode during basecalling. Rapid basecalling can be completed in real-time during the sequencing run. Alternatively, a high accuracy base-calling algorithm can be applied after completed sequencing run.

Input files format - *.fast5*
output files format - *.fastq*

Before starting the analysis, please check if Guppy directory is in your PATH varaible
```
export PATH=$PATH:/directory with Guppy installation/bin
echo $PATH #check if ~/ont-guppy-cpu/bin is in the PATH variable
```

ONT provides different types of library kits and flowcells. It is important to select the same kit/flowcell for basecalling to ensure accurate signal recognition. You may print a list of kits and flowcells as follows:
```
guppy_basecaller --print_workflows
```
This command will return a list of available library kits and flowcells:
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

Identify the right combination of a flowcell and library preparation kit. In this workflow, we are using the library "SQK-RBK004" and the flowcell "FLO-MIN106".

```
flowcell       kit               barcoding config_name                    model version
FLO-MIN106     SQK-PBK004        included  dna_r9.4.1_450bps_hac          2021-05-17_dna_r9.4.1_minion_384_d37a2ab9
```

Next, specify the input file, output directory, and the configuration name (remember to add configuration file extenstion (.cfg) at the end of the name).

**hac** is representing "high accuracy"

```
guppy_basecaller -i [input.fast5] -s [output directory] 
                 -c dna_r9.4.1_450bps_hac.cfg --num_callers 2 --cpu_threads_per_caller 1 --trim_barcodes
```
```
--num_callers: how many parallel basecallers to create
--cpu_threads_per_caller: how many threads will be used per each caller

[num_callers] * [cpu_threads_per_caller] = number of available threads

--trim_barcodes: barcode trimming based on the provided kit information
```

This will generate multiple *.fastq* files from a *.fast5* file in our output directory. You can simply combine all *.fastq* files into a single *.fastq* file as follows:
```
cd [output directory]
cat *.fastq > [output file name].fastq
```

This will generate a single, large *.fastq* file [output file name].fastq

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
