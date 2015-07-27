#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V

#########################################################################
# -- Author: Stephen Newhouse                                           #
# -- Organisation: KCL                                                  #
# -- Email: stephen.newkouse@kcl.ac.uk                                  #
#########################################################################

## Usage : sge_CleanUpWorkingDir.sh <working_dir>

##
working_dir=${1}
clinical_gender=${2}
multi_mapping_snps=${3}

echo "making new dir structure in " ${working_dir}

mkdir ${working_dir}/FINAL_ZCALL
mkdir ${working_dir}/zcall_proccessing
mkdir ${working_dir}/sge_out
mkdir ${working_dir}/plink_qc_tmp
mkdir ${working_dir}/scripts
mkdir ${working_dir}/manifest
mkdir ${working_dir}/clincial_gender
mkdir ${working_dir}/snp_information
mkdir ${working_dir}/sample_information

echo "moving Final Zcalls genotypes to   " ${working_dir}/FINAL_ZCALL/ " AND " ${working_dir}/FINAL_OPTICALL/

mv -v ${working_dir}/*_zcall_final* ${working_dir}/FINAL_ZCALL/
mv -v ${working_dir}/gender_missmatches ${working_dir}/FINAL_ZCALL/

##

mv -v ${working_dir}/*report_duplicate_sample_id_temp_changes ${working_dir}/sample_information/
cp ${working_dir}/het_outliers_sample_exclude ${working_dir}/sample_information/
cp ${working_dir}/related_sample_exclude ${working_dir}/sample_information/
cp ${working_dir}/FINAL_ZCALL/gender_missmatches ${working_dir}/sample_information/
cp ${working_dir}/samples_with_low_callrate_to_exclude ${working_dir}/sample_information/

##

mv -v ${working_dir}/${multi_mapping_snps} ${working_dir}/snp_information/
mv -v ${working_dir}/X_Y_XY_MT_chromosome_snps_IDs ${working_dir}/snp_information/
mv -v ${working_dir}/SNP_zeroed_in_genomestudio_to_remove ${working_dir}/snp_information/
mv -v ${working_dir}/SNP_IDs_to_remove ${working_dir}/snp_information/

##

mv -v ${working_dir}/${clinical_gender}* ${working_dir}/clincial_gender/

##
echo "moving zCall sd/beta/threshold files to  "${working_dir}/zcall_proccessing/

mv -v ${working_dir}/*.betas.txt ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*.mean.sd.txt ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*.output.thresholds* ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/optimal.thresh ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*_filt* ${working_dir}/zcall_proccessing/
mv -v ${working_dir}/*_Zcalls_UA* ${working_dir}/zcall_proccessing/

## 
echo "moving pre zcall and opticall plink qc files to  " ${working_dir}/plink_qc_tmp/

mv -v ${working_dir}/*.plinkQC_01* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.plinkQC_02* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.plinkQC_03* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*_exclude ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.plinkQC_04* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.plinkQC_05* ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/samples_zeroed_in_genomestudio ${working_dir}/plink_qc_tmp/

mv -v ${working_dir}/*.bed ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.bim ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.fam ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.log ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.map ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.nof ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.nosex ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.tfam ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.tped ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.ped ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*.pdf ${working_dir}/plink_qc_tmp/
mv -v ${working_dir}/*plinkQC_before_qc* ${working_dir}/plink_qc_tmp/

##
echo "moving scripts to " ${working_dir}/scripts/

mv -v ${working_dir}/*.sh ${working_dir}/scripts/

##
echo "moving sge out/errors to " ${working_dir}/sge_out/

mv -v ${working_dir}/*.e* ${working_dir}/sge_out/
mv -v ${working_dir}/*.o* ${working_dir}/sge_out/
mv -v ${working_dir}/*.po* ${working_dir}/sge_out/

##
echo "moving manifest to " ${working_dir}/manifest/

mv -v ${working_dir}/*.csv ${working_dir}/manifest/
mv -v ${working_dir}/update_alleles_file ${working_dir}/manifest/


