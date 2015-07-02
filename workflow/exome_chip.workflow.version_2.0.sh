#!/bin/bash

##########################################################################################################################################
####                                                                                                                                  ####
###     							                                                                       ###
##      -- Authors: Amos Folarin, Stephen Newhouse, Hamel Patel                                                                         ##
#       -- Organisation: KCL/SLaM/BRC-MH                          					                                 #
##      -- Email: amosfolarin@gmail.com, stephen.newhouse@kcl.ac.uk, hamel.patel@kcl.ac.uk	                                        ##
###                                                                                                                                    ###
####                                                                                                                                  ####
##########################################################################################################################################



# DESCRIPTION:

# Genotype calling for Exome Chip.
# This is the template script for running the exome chip pipeline which will run Zcall 
# from the input of a Genome Studio report file (zcall format, see docs)

# 1) Run QC on the report file
# 2) Run Zcall -- output:  <name>_filt_Zcall.bed
# 4) Run very basic QC on called genotypes : freq, HWE, missing and genotype based sex check
# 5) Cleans up working directory

#-------------------------------------------------------- USAGE ----------------------------------------------------------------#

##### require enviromnental variables populated correctly

# 1) exome_chip_bin = path to the pipeline bin with the scripts bin (....pipelines/exome_chip/bin/)
# available on 

# 2) zcall_bin = path to the zcall bin

# 3) working_dir= path to working dir, use pwd when run from the working dir (typical usage)


##### for each dataset run through the pipeline define these paths

# 4) manifest_file: illumina manifest file for the chip type

# 5) data_path = path to folder containing the genome studio report file 

# 6) basename = the filename root of the Genome Studio report file (in Zcall format)

# 7) multi_mapping_probe = list of multi mapping probes to remove



###############################
##### execute the pipeline ####
###############################


#-------------------------------------------------------------------------------------------------------------------------------#

echo " START PIPELINE " `date`

#------------------------------------------------------------------------
# Some environmental variables required for child processes (all) and 
# therefore are passed on by the environment variable -V in sge scripts
#------------------------------------------------------------------------

# scripts bins pathed -- use git repo versions

exome_chip_bin="/home/hpatelbrc/workspace/pipelines/exome_chip/bin/"

zcall_bin="/share/apps/zcall_current/Version3_GenomeStudio/bin/"

#----------------------------------##
## set/get OPTS from commanmd line ##
#----------------------------------##

working_dir=${1}  # PATH TO WHERE YOU WANT ALL OUTPUT
export PATH=$PATH:${exome_chip_bin}:${zcall_bin}:${opticall_bin}:${working_dir}
export data_path=${2} # PATH TO GS REPORT FILE
manifest_file=${3} # path to the manifest_file.csv: illumina manifest file for the chip type
multi_mapping_probes=${4} # list of SNP ID that have probes targetting multiple locations of the genome # if none supply empty list
clinical_gender=${5} # gender file in tab delimited format - no header - sample id tab gender
export basename=${6}  # leave off suffix ".report" for basename. Report file from genomestudio



###############
## set SGE Q ##
###############

queue_name="short.q,long.q" 


###########################
## create update alleles ##
###########################

qsub -q ${queue_name} -N create_allele_update_file ${exome_chip_bin}/create_update_allele_file_v02.sh ${manifest_file} 

######################### START INITIAL QC ##############################

#------------------------------------------------------------------------
# MAKE COPY OF REPORT FILE
echo -e "\nMaking a local copy of the report file"
# input: data location for gs.report
# output: working dir copy of gs.report
#-------------------------------------------------------------------------

cp -v ${data_path}/${basename}.report ${working_dir}/${basename}.report

#------------------------------------------------------------------------
# PREPARE REPORT FILE
echo -e "\nPreparing report file for Zcall"
# input: local report file
# output: report file amended
#------------------------------------------------------------------------

qsub -q ${queue_name} -N prep_report_file -hold_jid create_allele_update_file ${exome_chip_bin}/prepare_report_file.sh ${working_dir}/${basename}.report ${multi_mapping_probes}


#------------------------------------------------------------------------
# CONVERT REPORT FILE TO PED
echo -e "\nConvert GenomeStudio report file to Plink (ped) for QC input, output tped/tfam to working_dir"
# input: local gs.report
# output: local .tped & tfam files and ped & map files
#------------------------------------------------------------------------

qsub -q ${queue_name} -N report2ped -hold_jid prep_report_file ${exome_chip_bin}/sge_GSreport2ped_v02.sh ${working_dir}/${basename}.report_zcall_input

#------------------------------------------------------------------------
# INITIAL QC
echo -e "\nPost-GenomeStudio Sample QC, output list of samples to drop "
# input: .ped file derived from the report
# output: output list of samples to drop: final_sample_exclude
# *****//TODO still some outstanding QC steps to implement*****
#------------------------------------------------------------------------

qsub -q ${queue_name} -N initial-QC -hold_jid report2ped ${exome_chip_bin}/exome.qc.pipeline.v06.sh ${working_dir}/${basename}.report_zcall_input ${working_dir}/${basename}.report_zcall_input ${exome_chip_bin} X_Y_XY_MT_chromosome_snps_IDs

#------------------------------------------------------------------------
# INITIAL QC
echo -e "\nDrop only samples with low call rate from gs.report (local)"
echo -e "\nALL subsequent work carried out on the ${basename}_filt.report, which is the QC'd file"
# input: report file and samples to exclude
# output: report file ${basename}_filt.report cleaned of bad samples
#------------------------------------------------------------------------

qsub -q ${queue_name} -N drop-bad-samples -hold_jid initial-QC ${exome_chip_bin}/sge_dropBadSamples_v02.sh ${working_dir}/${basename} ${working_dir}/samples_with_low_callrate_to_exclude

######################### END INITIAL QC ##############################




######################### START OF ZCALL ##############################

#------------------------------------------------------------------------
# ZCALL BRANCH:
echo -e "\nCalibrate Z, find Z which has the best concordance with Gencall"
echo -e "\nThe R script global.concordance.R will calculate the optimal z"
# input: working directory, minimum intensity (default value 0.2)
# output: zcall threshold files, stats files
#------------------------------------------------------------------------

qsub -q ${queue_name} -N calcThresh -hold_jid drop-bad-samples ${exome_chip_bin}/sge_calcThresholds.sh ${working_dir}/${basename}_filt 0.2
qsub -q ${queue_name} -N gConcordance -hold_jid calcThresh ${exome_chip_bin}/sge_global_concordance.sh ${working_dir}


#------------------------------------------------------------------------
# ZCALL BRANCH:
echo -e "\nRun Z call, with the calibrated threshold file"

# input: basename and optimal threshold file, this is listed in the "optimal.thresh" file after running global concordance
# output: zcalls in tped/tfam Plink format
#------------------------------------------------------------------------
#run with precalculated threshold file

qsub -q ${queue_name} -N zcalling -hold_jid gConcordance ${exome_chip_bin}/sge_zcall.sh ${working_dir} ${basename}_filt ${working_dir}/optimal.thresh

#------------------------------------------------------------------------
# ZCALL BRANCH:
# POST CALLING STEPS:

echo -e "\nUpdating Alleles for ZCall tped to Illumina top strand"

# plink update-alleles
# input: basename of zcall tped
# output: .bed file with updated alleles
#------------------------------------------------------------------------

qsub -q ${queue_name} -N update-alleles_zc -hold_jid zcalling ${exome_chip_bin}/sge_update-alleles.sh ${working_dir}/${basename}_filt_Zcalls "update_alleles_file"

######################### END OF ZCALL ##############################

########################### POST QC #################################

#------------------------------------------------------------------------
# BASIC QC

echo -e "\nRunning basic QC on PLINK output"i

qsub -q ${queue_name} -N basic_post_qc -hold_jid update-alleles_zc ${exome_chip_bin}/basic_plinkqc_after_zcall.sh ${working_dir}/${basename} ${clinical_gender}

# input: zcall_UA
# output zcall_final
#------------------------------------------------------------------------

# SUMMARY REPORT

qsub -q ${queue_name} -N summary_report -hold_jid basic_post_qc ${exome_chip_bin}/create_summary_report.sh ${basename} ${multi_mapping_probes}

# CLEAN UP DIRECTORY

echo -e "\nCleaning directory"

qsub -q ${queue_name} -N CleanUpWorkingDir -hold_jid summary_report ${exome_chip_bin}/sge_CleanUpWorkingDir_v02.sh ${working_dir} ${clinical_gender} ${multi_mapping_probes} 


####################### END OF POST QC ##############################

#echo " END PIPELINE " `date`

 







