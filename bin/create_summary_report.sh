#!/bin/bash
#$ -S /bin/sh
#$ -l h_vmem=10G
#$ -pe multi_thread 1
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

number_of_related_samples_temp=$(wc -l "related_sample_exclude" | awk '{print $1}')

number_of_related_samples=$(echo $(( $number_of_related_samples_temp - 1)))

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
##	CREATE SUMMARY REPORT
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

echo -e "\nNumber of samples to be aware of due to heterozygote variability: $number_of_het_samples		...see file '"sample_information/het_outliers_sample_exclude"' for sample IDs" >> README_summary_report

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
Het, related, duplicate and samples with low call rate are located within '"sample_information"' folder." >> README_summary_report



echo -e "\n*************************************************End**************************************************************\n" >> README_summary_report











