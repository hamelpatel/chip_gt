#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V


##########################################################################################################################################
####                                                                                                                                  ####
###                                                                                                                                    ###
##                                                                                                                                      ##
#                                               BASIC QC ON ZCALL OUTPUT	                                                         #
##                                                                                                                                      ##
###                                                                                                                                    ###
####                                                                                                                                  ####
##########################################################################################################################################


module add bioinformatics/plink2/1.90b3.38
module add utiltities/dos2unix/7.4.0

zcall_bed=${1}
clinical_gender=${2}

##
##	UPDATE GENDER INFORMATION INTO FINAL PLINK FILES
##

#
#	convert gender file:
#	Male 	-> 1
#	female	-> 2
#	Unknown	-> 0
#

dos2unix ${clinical_gender}

# remove duplicate samples - 

cut -f1 ${clinical_gender} | sort | uniq -c | awk '$1>1' | awk '{print $2}' > ${clinical_gender}_duplicate_ids_to_exclude_temp

fgrep -wvf ${clinical_gender}_duplicate_ids_to_exclude_temp ${clinical_gender} > ${clinical_gender}_no_dups

# convert to unix
dos2unix ${clinical_gender}_no_dups

awk 'BEGIN {OFS="\t"} \
	{if($2=="Male" || $2=="M" || $2=="male" || $2=="m" || $2=="MALE") print $1, $1, "1" ; \
	else if($2=="Female" || $2=="F" || $2=="female" || $2=="f" || $2=="FEMALE") print $1, $1, "2" ; \
	else print $1, $1, "0"}' ${clinical_gender}_no_dups > ${clinical_gender}_plink_input


plink --noweb \
--bfile ${zcall_bed}_filt_Zcalls_UA \
--update-sex ${clinical_gender}_plink_input \
--make-bed \
--out ${zcall_bed}_zcall_final


##
##      CONVERT SNP IDS WITH "rs_temp" BACK TO "snp"
##

sed 's/rs_temp/SNP/g' ${zcall_bed}_zcall_final.bim > ${zcall_bed}_zcall_final.bim_temp

mv ${zcall_bed}_zcall_final.bim_temp ${zcall_bed}_zcall_final.bim


##
##	CONVERT DUPLIACTE IDs BACK IN FINAL FILE
##

cat ${zcall_bed}.report_duplicate_sample_id_temp_changes | while read line
	do
	changed_id=$(echo $line | awk '{print $6}')
	old_id=$(echo $line | awk '{print $4}')
	sed "s/${changed_id}/${old_id}/g" ${zcall_bed}_zcall_final.fam > ${zcall_bed}_zcall_final.fam_temp
	mv ${zcall_bed}_zcall_final.fam_temp ${zcall_bed}_zcall_final.fam
	echo $changed_id
	echo $old_id
	done


##
##	GENERATE FREQ, HWE AND MISSINGNESS
##

for i in freq hardy missing;do
plink --noweb \
--bfile ${zcall_bed}_zcall_final \
--allow-no-sex \
--out ${zcall_bed}_zcall_final \
--${i};
done;

##
##	COUNTS
##

plink --noweb \
--out ${zcall_bed}_zcall_final \
--freq --counts;

##
##	GENDER-MISS MATCH CHECK 
##

plink --noweb \
--bfile ${zcall_bed}_zcall_final \
--allow-no-sex \
--out ${zcall_bed}_zcall_final \
--chr 23 \
--maf 0.05 \
--geno 0.02 \
--check-sex;

head -1 ${zcall_bed}_zcall_final.sexcheck > gender_missmatches

awk 'BEGIN {OFS="\t"} NR >1 \
	{if($3 != $4 && $3 != "0" && $4 !=0) print $0}' ${zcall_bed}_zcall_final.sexcheck >> gender_missmatches











