#!/bin/bash
#$ -S /bin/sh
#$ -l h_vmem=10G
#$ -j yes
#$ -cwd
#$ -V


##########################################################################################################################################
####                                                                                                                                  ####
###                                                                                                                                    ###
##                                                                                                                                      ##
#	                                              	CREATE SUMMARY REPORT                                                    	 #
##                                                                                                                                      ##
###                                                                                                                                    ###
####                                                                                                                                  ####
##########################################################################################################################################


report_file=${1}
multimapping_snp_file=${2}

##
##	SNP/SAMPLE NUMBER BEFORE QC
##

total_snp_number_prior_to_qc_temp=$(wc -l ${report_file}.report | awk '{print $1}')

total_snp_number_prior_to_qc=$(echo $(( $total_snp_number_prior_to_qc_temp - 1)))

total_sample_number_prior_to_qc=$(head -1 ${report_file}.report | sed s'/\t/\n/g' | grep GType | wc -l)

##
##	SNP/SAMPLE NUMBER AFTER QC
##

total_snp_number_after_qc=$(wc -l ${report_file}_zcall_final.bim | awk '{print $1}')

total_sample_number_after_qc=$(wc -l ${report_file}_zcall_final.fam | awk '{print $1}')

##
##	NUMBER OF DUPLICATE SAMPLES
##

number_of_duplicate_samples=$(wc -l ${report_file}.report_duplicate_sample_id_temp_changes | awk '{print $1}')

##
##	NUMBER OF HET SAMPLES
##

number_of_het_samples=$(wc -l "het_outliers_sample_exclude" | awk '{print $1}')

##
##	NUMBER OF RELATED SAMPLES
##

#number_of_related_samples_temp=$(sort related_sample_exclude | uniq -c | wc -l)

#number_of_related_samples=$(echo $(( $number_of_related_samples_temp - 1)))

number_of_related_samples=$(sort related_sample_exclude | uniq -c | wc -l)


##
##	NUMBER OF GENDER MISSMATCHES
##

number_of_gender_missmatches_temp=$(wc -l "gender_missmatches" | awk '{print $1}')

number_of_gender_missmatches=$(echo $(( $number_of_gender_missmatches_temp - 1)))

##
##	NUMBER OF SNPS REMOVED DUE TO FAILING GENOMESTUDIO STAGE
##

number_of_snps_failed_genomestudio=$(wc -l "SNP_zeroed_in_genomestudio_to_remove" | awk '{print $1}')

##
##	NUMBER OF MULTIMAPPING SNPS REMOVED
##

number_of_multimapping_snps=$( wc -l ${multimapping_snp_file} | awk '{print $1}')

##
##	NUMBER OF SAMPLES WITH A LOW CALL RATE REMOVED
##

number_of_samples_with_low_call_rate=$(wc -l "samples_with_low_callrate_to_exclude" | awk '{print $1}')

##
##	CREATE SUMMARY REPORT - basic
##


echo -e "\n*************************************************Summary Report**************************************************"  > README_summary_report

echo -e "\nPlease note: unless specified, any Het or related samples have not been removed, but only identified for users awareness.
Duplicate samples, if any, have been changed to a unique id run through the QC pipeline and converted back to original form.
All temp ID changes are listed in '"sample_information/${report_file}.report_duplicate_sample_id_temp_changes"'
SNP probes which target multiple regions of the genome have been identified and removed. These SNP IDs are found in '"snp_information/${multimapping_snp_file}"'
All alleles have been converted to Illumina top strand" >> README_summary_report

echo -e "\nA summary of the pipeline analysis is given below:" >> README_summary_report

echo -e "\nTotal number of SNPs prior QC: $total_snp_number_prior_to_qc" >> README_summary_report

echo -e "\nTotal number of Samples prior to QC: $total_sample_number_prior_to_qc" >> README_summary_report

echo -e "\nTotal number of mulimapping SNPs removed: $number_of_multimapping_snps		...see file: '"snp_information/${multimapping_snp_file}"' for SNP IDs" >> README_summary_report

echo -e "\nTotal number of SNPs removed due to failing genomestudio stage: $number_of_snps_failed_genomestudio		...see file: '"snp_information/SNP_zeroed_in_genomestudio_to_remove"' for SNP IDs" >> README_summary_report

echo -e "\nNumber of samples removed due to call rate below 98%: $number_of_samples_with_low_call_rate			...see file: '"sample_information/samples_with_low_callrate_to_exclude"' for sample IDs " >> README_summary_report

echo -e "\nTotal number of SNPs after QC: $total_snp_number_after_qc" >> README_summary_report

echo -e "\nTotal number of Samples after QC: $total_sample_number_after_qc" >> README_summary_report

echo -e "\nNumber of duplicate samples: $number_of_duplicate_samples		...see file: '"sample_information/${report_file}.report_duplicate_sample_id_temp_changes"' for sample IDs " >> README_summary_report

echo -e "\nNumber of samples to be aware of due to heterozygosity: $number_of_het_samples		...see file '"sample_information/het_outliers_sample_exclude"' for sample IDs" >> README_summary_report

echo -e "\nNumber of related samples identified: $number_of_related_samples		...see file '"sample_information/related_sample_exclude"' for sample IDs" >> README_summary_report

echo -e "\nNumber of gender missmatches identified: $number_of_gender_missmatches		...see file '"sample_information/gender_missmatches"' for sample IDs" >> README_summary_report

echo -e "\nTotal number of SNPs after QC: $total_snp_number_after_qc" >> README_summary_report

echo -e "\nTotal number of Samples after QC: $total_sample_number_after_qc" >> README_summary_report



echo -e "\nThe data has been run through Zcall. The PLINK output files are in the '"FINAL_ZCALL"' folder. 
All processing files for Zcall are located within the '"zcall_proccessing"' folder.
All sungrid processing files and error logs are located within the '"sge_out"' folder.
All PLINK QC processing files are located within the '"plink_qc_tmp" folder.
The main workfow script is located within the '"scripts"' folder.
The genotype chip's manifest and update allele file is located within the '"manifest"' folder.
The clinical gender used to update the plink files are located within the '"clincial_gender"' folder.
SNP IDs identified as multi-mapping or problematic during the GenomeStudio stage are located in the '"snp_information"' folder.
A copy of the genomestudio file is locted in the working directory ('"${report_file}.report"') along with a QC'd file used for zcall input ('"${report_file}.report_zcall_input"').
Het, related, duplicate and samples with low call rate are located within '"sample_information"' folder." >> README_summary_report



echo -e "\n*************************************************End**************************************************************\n" >> README_summary_report

##
##	CREATE MARKDOWN REPORT
##


echo -e "# BRC Bioinformatics Core: Genotyping Summary Report

|  Info | Illumina Genotyping Pipeline Report |
|----------|---------|
|**Author**| Hamel Patel, <hamel.patel@kcl.ac.uk>|
|**Date:** |$(date)|
|**Pipeline Version:** |exome\_chip.workflow.version\_2.0.sh|
|**github:** |https://github.com/KHP-Informatics/chip_gt|
|**SOP:** | https://confluence.brc.iop.kcl.ac.uk:8493/display/PUB/Production+Version%3A+Illumina+Exome+Chip+SOP+v1.4|

---

##Authors

###Laboratory contact:

+ **Dr Charles Curtis**
    - charles.curtis@kcl.ac.uk

###Bioinfomatics contacts:

+ **Dr Stephen Newhouse**
    - stephen.newhouse@kcl.sc.uk

+ **Dr Amos Folarin**
    - amos.folarin@kcl.ac.uk

+ **Mr Hamel Patel**
    - hamel.patel@kcl.ac.uk

---
## Illumina Genotyping Pipeline

Raw Illumina microarray genotype image IDAT files are uploaded into GenomeStudio and thoroughly QC'd using our [SOP](https://confluence.brc.iop.kcl.ac.uk:8493/display/PUB/Production+Version%3A+Illumina+Exome+Chip+SOP+v1.4). A report file is created and passed through our QC [pipeline](https://github.com/KHP-Informatics/chip_gt).

A number of SNPs have been identified through lluminas beadchip manifest, where the probe targets multiple locations of the genome. These SNPs have been removed from all analysis.

Any duplicate sample IDs are renamed to a unique ID, processed through our QC pipeline, and renamed to original sample ID once QC finishes. This gives each sample a unique ID and prevents the removal of all duplicate sample IDs if one was to fail the call rate threshold.

Using only autosomal SNPs, SNPs and samples are iteratively removed which have a call rate below 0.95 and 0.98 respectively. Regions with LD are removed, after which samples with outlying heterozygote rates and related samples are identified for users. SNPs with a low call rate are re-introduced.

Only samples with a low call rate, multi-mapping SNPs and SNPs identified as problematic during the genomestudio phase are removed, after which the project is processed by the rare variant caller ZCall. The output file from this is given to the user as the end product.

All alleles have been converted to Illumina top strand

Any clinical/genetical gender miss-matches are identified for user.


---

## Genotype Data & Sample/SNP Exclude Files

These are [PLINK](http://pngu.mgh.harvard.edu/~purcell/plink/data.shtml#bed) Binary Files. 

#### PLINK Binary files (BED/BIM/FAM)

Extra details on file format can be found [here](http://www.gwaspi.org/?page_id=671)

| Data File | Name |
|-----------|-------|
| BED | FINAL\_ZCALL/${report_file}\_zcall\_final.bed |
| BIM | FINAL\_ZCALL/${report_file}\_zcall\_final.bim |
| FAM | FINAL\_ZCALL/${report_file}\_zcall\_final.fam |
| SAMPLE Excluded | sample\_information/samples\_with\_low\_callrate\_to\_exclude |
| SNP Excluded | snp\_information/mega\_array\_probes\_hybridising\_to\_more\_than\_1\_location\_of\_genome\_SNP\_ID\_to\_remove |


##Pipeline summary:

+ **Total number of SNPs prior QC:** $total_snp_number_prior_to_qc

+ **Total number of Samples prior to QC:** $total_sample_number_prior_to_qc

+ **Total number of mulimapping SNPs removed:** $number_of_multimapping_snps
    - _see file: snp\_information/${multimapping_snp_file} for SNP IDs_

+ **Total number of SNPs removed due to failing genomestudio stage:** $number_of_snps_failed_genomestudio
    - _see file: snp\_information/SNP\_zeroed\_in\_genomestudio\_to\_remove for SNP IDs_

+ **Number of samples removed due to call rate below 98%:** $number_of_samples_with_low_call_rate
    - _see file: sample\_information/samples\_with\_low\_callrate\_to\_exclude for sample IDs_ 

+ **Total number of SNPs after QC:** $total_snp_number_after_qc

    - _see file: sample\_information/${report_file}.report\_duplicate\_sample\_id\_temp\_changes for sample IDs_

+ **Number of samples to be aware of due to heterozygosity:** $number_of_het_samples
    - _see file sample\_information/het\_outliers\_sample\_exclude for sample IDs_

+ **Number of related samples identified:** $number_of_related_samples
    - _see file sample\_information/related\_sample\_exclude for sample IDs_

+ **Number of gender missmatches identified:** $number_of_gender_missmatches
    - _see file sample\_information/gender\_missmatches for sample IDs_

## Further Analysis
**Data provided need to be run through standard GWAS QC prior to any further analysis.**

All we have provided are a set of clean genotype calls and lists of SNPs and Samples that the end user should consider removing. A good guide/scripts for GWAS analysis can be found [here](https://github.com/JoniColeman/gwas_scripts)

**PLINK DATA MANAGEMENT :** 

PLINK data management can be found [here](http://pngu.mgh.harvard.edu/~purcell/plink/dataman.shtml)

---

##Notes:

The data has been run through Zcall. The PLINK output files are in the _FINAL\_ZCALL_ folder. 

All processing files for Zcall are located within the _zcall\_proccessing_ folder.

All sungrid processing files and error logs are located within the _sge\_out_ folder.

All PLINK QC processing files are located within the _plink\_qc\_tmp_ folder.

The main workfow script is located within the _scripts_ folder.

The genotype chip's manifest and update allele file is located within the _manifest_ folder.

The clinical gender used to update the plink files are located within the _clincial\_gender_ folder.

SNP IDs identified as multi-mapping or problematic during the GenomeStudio stage are located in the _snp\_information_ folder.

Het, related, duplicate and samples with low call rate are located within _sample\_information_ folder.



***
(c) 2015 Hamel Patel, BRC Bioinformatics Core" > README_summary_report.mkd




##
##	 CONVERT MARKDOWN TO HTML
##


/users/k1223459/brc_scratch/Genotype/chip_gt/grip README_summary_report.mkd --export README_summary_report.html



