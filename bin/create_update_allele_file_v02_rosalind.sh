#!/bin/bash
#$ -S /bin/sh
#$ -l h_vmem=10G
#$ -j yes
#$ -cwd
#$ -V



##########################################################################################
##											##
##	converts illumina genotype manifest.csv file to A/B update allele file		##
##											##
##########################################################################################



manifest=$1

awk -F, 'BEGIN {OFS="\t"} NR>8 && NF>6 {\
        if ($3=="TOP") print $2, "A B", substr($4, 2, 1)" "substr($4, 4, 1) ;\
        else if ($3=="BOT" && $4=="[A/G]") print $2, "A B", "T C";\
        else if ($3=="BOT" && $4=="[A/C]") print $2, "A B", "T G";\
        else if ($3=="BOT" && $4=="[A/T]") print $2, "A B", "T A";\
        else if ($3=="BOT" && $4=="[C/A]") print $2, "A B", "G T";\
        else if ($3=="BOT" && $4=="[C/G]") print $2, "A B", "G C";\
        else if ($3=="BOT" && $4=="[C/T]") print $2, "A B", "G A";\
        else if ($3=="BOT" && $4=="[G/A]") print $2, "A B", "C T";\
        else if ($3=="BOT" && $4=="[G/C]") print $2, "A B", "C G";\
        else if ($3=="BOT" && $4=="[G/T]") print $2, "A B", "C A";\
        else if ($3=="BOT" && $4=="[T/A]") print $2, "A B", "A T";\
        else if ($3=="BOT" && $4=="[T/G]") print $2, "A B", "A C";\
        else if ($3=="BOT" && $4=="[T/C]") print $2, "A B", "A G";\
        else print $2, "A B", substr($4, 2, 1)" "substr($4, 4, 1)}'\
        $manifest > "update_alleles_file" 


