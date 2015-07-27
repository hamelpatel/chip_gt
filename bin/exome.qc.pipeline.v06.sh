#!/bin/sh
#$ -S /bin/sh
#$ -l h_vmem=10G
#$ -pe multi_thread 1
#$ -j yes
#$ -cwd
#$ -V
############################

pedfile=${1}
bedfile=${2}
exome_chip_bin=${3}
Y_chromo_snps=${4}

##
##	1.REMOVE SEX & MT CHROMOSOMES SNPS AND CONVERT TO PLINK BINARY
##

echo -e "\n- Excluding Y chromsome SNPs and converting ped to bed -"
plink2 --noweb \
--tfile ${pedfile} \
--exclude ${Y_chromo_snps} \
--make-bed \
--out ${bedfile}.plinkQC_before_qc;


##
##	2.RUN BASIC QC CHECKS - MISSINGNESS, FREQ, HARDY
##

echo -e "\n- Running initial qc check -"
for my_qc in missing freq hardy;do
plink2 --noweb --bfile ${bedfile}.plinkQC_before_qc --${my_qc} --out ${bedfile}.plinkQC_before_qc;
done

##
##	2.1 - REMOVE ALL SAMPLES WHICH HAVE BEEN ZEROED IN GENOMESTUDIO STAGE - 1.E CALL RATE ZERO - snps which have been zeroed in genomestudio stage have been removed in earlier stages - implemented 24/7/2015 H.P
##

awk 'NR>1 {if ($6==1) print $1}' ${bedfile}.plinkQC_before_qc.lmiss > samples_zeroed_in_genomestudio

#remove low call rate samples
plink2 --noweb \
--bfile ${bedfile}.plinkQC_before_qc \
--make-bed \
--out ${bedfile}.plinkQC_01 \
--remove samples_zeroed_in_genomestudio;

# run basic qc

echo -e "\n- Running basic qc 01 -"
for my_qc in missing freq hardy;do
plink2 --noweb --bfile ${bedfile}.plinkQC_01 --${my_qc} --out ${bedfile}.plinkQC_01;
done

##
##      3.QC STAGE PHASE 1 - ID AND REMOVE SNPS WITH CALL RATE < 0.9
##

#ID snps with call rate <0.9
cat ${bedfile}.plinkQC_01.lmiss | awk '$5>=0.10'> ${bedfile}.plinkQC_01_poor_snp_callrate;
cat ${bedfile}.plinkQC_01.lmiss | awk '$5>=0.10'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}.plinkQC_01_poor_snp_callrate_to_exclude;

echo -e "\n- Removing snps with call rate < 90% -"

#remove low call rate snp
plink2 --noweb \
--bfile ${bedfile}.plinkQC_01 \
--make-bed \
--out ${bedfile}.plinkQC_01_0.9_snp_callrate_removed \
--exclude ${bedfile}.plinkQC_01_poor_snp_callrate_to_exclude;


##
##	4.QC STAGE PHASE 2 - ID AND REMOVE SAMPLES WITH CALL RATE < 0.9
##

# recalculate missingness
plink2 --noweb \
--bfile ${bedfile}.plinkQC_01_0.9_snp_callrate_removed \
--missing --out ${bedfile}.plinkQC_02

# ID samples with call rate below 0.9
cat ${bedfile}.plinkQC_02.imiss | awk '$6>=0.10'> ${bedfile}.plinkQC_02_poor_sample_callrate;
cat ${bedfile}.plinkQC_02.imiss | awk '$6>=0.10'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}.plinkQC_02_poor_sample_callrate_to_exclude;

echo -e "\n- Removing samples with call rate < 90% -"

# remove low call rate smaples
plink2 --noweb \
--bfile ${bedfile}.plinkQC_01_0.9_snp_callrate_removed \
--make-bed \
--out ${bedfile}.plinkQC_02_0.9_sample_callrate_removed \
--remove ${bedfile}.plinkQC_02_poor_sample_callrate_to_exclude;


##
##      5.QC STAGE PHASE 3 - ID AND REMOVE SNPS WITH CALL RATE < 0.95
##

# recalculate missingness
plink2 --noweb \
--bfile ${bedfile}.plinkQC_02_0.9_sample_callrate_removed \
--missing --out ${bedfile}.plinkQC_03

#ID snps with call rate <0.95
cat ${bedfile}.plinkQC_03.lmiss | awk '$5>=0.05'> ${bedfile}.plinkQC_03_poor_snp_callrate;
cat ${bedfile}.plinkQC_03.lmiss | awk '$5>=0.05'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}.plinkQC_03_poor_snp_callrate_to_exclude;

echo -e "\n- Removing snps with call rate < 95% -"

#remove low call rate snp
plink2 --noweb \
--bfile ${bedfile}.plinkQC_02_0.9_sample_callrate_removed \
--make-bed \
--out ${bedfile}.plinkQC_03_0.95_snp_callrate_removed \
--exclude ${bedfile}.plinkQC_03_poor_snp_callrate_to_exclude;


##
##      6.QC STAGE PHASE 4 - ID AND REMOVE SAMPLES WITH CALL RATE < 0.98
##

# recalculate missingness
plink2 --noweb \
--bfile ${bedfile}.plinkQC_03_0.95_snp_callrate_removed \
--missing --out ${bedfile}.plinkQC_04

# ID samples with call rate below 0.8
cat ${bedfile}.plinkQC_04.imiss | awk '$6>=0.02'> ${bedfile}.plinkQC_04_poor_sample_callrate;
cat ${bedfile}.plinkQC_04.imiss | awk '$6>=0.02'| sed '1,1d' | awk '{print $1,$2}' > ${bedfile}.plinkQC_04_poor_sample_callrate_to_exclude;

echo -e "\n- Removing samples with call rate < 98% -"

# remove low call rate smaples
plink2 --noweb \
--bfile ${bedfile}.plinkQC_03_0.95_snp_callrate_removed \
--make-bed \
--out ${bedfile}.plinkQC_04_0.98_sample_callrate_removed \
--remove ${bedfile}.plinkQC_04_poor_sample_callrate_to_exclude;

##
##	7.PLOT MISSINGNESS BEFORE AND AFTER QC
##

#before
R --vanilla --slave --args bfile=${bedfile}.plinkQC_01 < plot.missingness.v02_before_QC.r;

#after
R --vanilla --slave --args bfile=${bedfile}.plinkQC_04_0.98_sample_callrate_removed < plot.missingness.v02_after_QC.r;


##
##	8.LIST OF COMMON AND RARE SNPS
##


for my_qc in missing freq hardy;do
plink2 --noweb \
--bfile ${bedfile}.plinkQC_04_0.98_sample_callrate_removed \
--${my_qc} \
--out ${bedfile}.plinkQC_04_0.98_sample_callrate_removed;
done


cat ${bedfile}.plinkQC_04_0.98_sample_callrate_removed.frq | awk '$5>=0.05'> ${bedfile}.plinkQC_04_0.98_sample_callrate_removed_common_snps;
cat ${bedfile}.plinkQC_04_0.98_sample_callrate_removed.frq | awk '$5>=0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}.plinkQC_04_0.98_sample_callrate_removed_common_snps_list;
cat ${bedfile}.plinkQC_04_0.98_sample_callrate_removed.frq | awk '$5<0.05' | sed '1,1d' | awk '{print $2}' > ${bedfile}.plinkQC_04_0.98_sample_callrate_removed_rare_snps_list;


##
##	9.QC STAGE PHASE 5 LD prune
##

echo -e "\n- ld prune -"

plink2 --noweb \
--bfile ${bedfile}.plinkQC_04_0.98_sample_callrate_removed \
--indep-pairwise 500 50 0.50 \
--maf 0.05 \
--out ${bedfile}.plinkQC_04_0.98_sample_callrate_removed;

plink2 --noweb \
--bfile ${bedfile}.plinkQC_04_0.98_sample_callrate_removed \
--maf 0.05 \
--geno 0.10 \
--make-bed \
--out ${bedfile}.plinkQC_05_LDpruned \
--extract ${bedfile}.plinkQC_04_0.98_sample_callrate_removed.prune.in;

##
##	10.ID HET SAMPLES
##


echo -e "\n- het -"

plink2 --noweb \
--bfile ${bedfile}.plinkQC_05_LDpruned \
--het \
--maf 0.05 \
--geno 0.10 \
--out ${bedfile}.plinkQC_05_LDpruned;

Rscript ${exome_chip_bin}/removehets.R ${bedfile}.plinkQC_05_LDpruned.het;

## produces ${bedfile}.plinkQC_03_LDpruned.het.sample.remove

mv ${bedfile}.plinkQC_05_LDpruned.het.sample.remove  het_outliers_sample_exclude


##
##	11.ID RELATED SAMPLES
##

plink2 \
--noweb \
--bfile ${bedfile}.plinkQC_05_LDpruned \
--allow-no-sex \
--out ${bedfile}.plinkQC_05_LDpruned \
--Z-genome;

zcat ${bedfile}.plinkQC_05_LDpruned.genome.gz | awk '$10>0.1875' > ${bedfile}.plinkQC_05_LDpruned.genome.related;

cat ${bedfile}.plinkQC_05_LDpruned.genome.related | awk '{print $1"\t"$2}' > ${bedfile}.plinkQC_05_LDpruned.genome.related.sample.remove;

mv ${bedfile}.plinkQC_05_LDpruned.genome.related.sample.remove related_sample_exclude;


### FINAL LIST OF BAD SAMPLES

cat *poor_sample_callrate_to_exclude >> samples_with_low_callrate_temp

cat samples_zeroed_in_genomestudio >> samples_with_low_callrate_temp

cat samples_with_low_callrate_temp | awk '{print $2}' | sort | uniq > samples_with_low_callrate_to_exclude


### FINAL LIST OF SNPS TO REMOVE

cat *poor_snp_callrate_to_exclude >> snps_with_low_callrate_temp

cat snps_with_low_callrate_temp | awk '{print $2}' | sort | uniq > snps_with_low_callrate_to_exclude

rm samples_with_low_callrate_temp snps_with_low_callrate_temp




