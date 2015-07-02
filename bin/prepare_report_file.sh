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
#          					PREPARE .REPORT FILE FOR QC PIPELINE                    				 #
##                                                                                                                                      ##
###                                                                                                                                    ###
####                                                                                                                                  ####
##########################################################################################################################################

## INPUT .REPORT FILE

report_file=$1

multi_mapping_snp=$2

##
##	MAKE A LIST OF SNPS WHICH HAVE BEEN ZEROED OUT DURING THE GENOEMSTUDIO STAGE
##

# count the occurance "NC" per line on temp report file

awk '{print $1"\t"gsub(/NC/,"")}' ${report_file} >${report_file}_NC_count

# count number of samples in report file

number_of_samples=$(head -1 ${report_file} | sed 's/\t/\n/g' | fgrep GType | wc -l)

# extract snp id where NC==number_of_samples

awk -v count="$number_of_samples" '{if($2==count) print $1}' ${report_file}_NC_count > SNP_zeroed_in_genomestudio_to_remove

##
##	MERGE MULTI MAPPING SNP AND 0 CALL RATE SNP TOGETHER
##

cat ${multi_mapping_snp} SNP_zeroed_in_genomestudio_to_remove > SNP_IDs_to_remove


##
##	REMOVE BAD SNPs
##

fgrep -wvf SNP_IDs_to_remove ${report_file} > ${report_file}_bad_snps_removed

##
##	CONVERT ANY "SNP" id to "rs_temp"
##

sed 's/SNP/rs_temp/g' ${report_file}_bad_snps_removed > ${report_file}_zcall_input

##
##	RENAME DUPLICATE SAMPLES
##


# replace duplicate ids
#       sample - sample
#       sample - sample_duplicate_1
#       sample - sample_duplicate-2
#       etc..
#
#       work on header file only
#



echo -e "\nChecking for duplicate sample ID's...\n"

head -1 ${report_file} | sed 's/\t/\n/g' | grep "GType" | sort | uniq -c | awk '{if($1>1) print $2}' | sed 's/.GType//g' > ${report_file}_DUPLICATE_SAMPLES

if [ -s ${report_file}_DUPLICATE_SAMPLES ] ;
        then
                echo -e "\n*****WARNING DUPLICATE SAMPLE ID's PRESENT.... SAMPLES ID's WILL BE TEMPORARILY RENAMED!*****\n" 
		head -1 ${report_file}_zcall_input > ${report_file}_duplicate_samples_renamed_temp1
		tail -n +2 ${report_file}_zcall_input > ${report_file}_duplicate_samples_renamed_temp2
		cat ${report_file}_duplicate_samples_renamed_temp1 | sed 's/\t/\n/g' | grep "GType" | sed 's/.GType//g' | sort | uniq -c | awk '{if($1>1) print $0}' | sort -k1r > ${report_file}_duplicate_sample_ids
		cat ${report_file}_duplicate_sample_ids | while read lines ;
        		do
 			       no_duplicted_times=`echo $lines | awk '{print $1}'`
 			       duplicate_sample_id=`echo $lines | awk '{print $2}'`
			       count=1
			                while [ $count -lt $no_duplicted_times ] ;
			                        do
				                        replacement=`echo -e "${duplicate_sample_id}_duplicate_${count}"`
			        	                sed -i  "0,/$duplicate_sample_id.GType/s/$duplicate_sample_id.GType/$replacement.GType/" ${report_file}_duplicate_samples_renamed_temp1
				                        sed -i  "0,/$duplicate_sample_id.X/s/$duplicate_sample_id.X/$replacement.X/" ${report_file}_duplicate_samples_renamed_temp1
				                        sed -i  "0,/$duplicate_sample_id.Y/s/$duplicate_sample_id.Y/$replacement.Y/" ${report_file}_duplicate_samples_renamed_temp1
				                        count=$(($count + 1))
				                        echo -e "Changed sample ID $duplicate_sample_id to $replacement" | tee -a ${report_file}_duplicate_sample_id_temp_changes
			                        done
			done
			cat ${report_file}_duplicate_samples_renamed_temp1 ${report_file}_duplicate_samples_renamed_temp2 > ${report_file}_zcall_input
		rm ${report_file}_duplicate_samples_renamed_temp1 ${report_file}_duplicate_samples_renamed_temp2 ${report_file}_duplicate_sample_ids
	else
		echo -e "\nNo duplicate samples ID's found...continuing with pipeline\n"
	fi



##
##	SEPARATE X, Y, XY, MT FROM AUTOSOMAL CHROMSOMES - make just id list
##


awk '{print $1"\t"$2}' ${report_file}_zcall_input | awk '{if($2=="Y" || $2=="XY" || $2=="X" || $2=="MT") print $1}' > "X_Y_XY_MT_chromosome_snps_IDs"


# remove temp file

rm ${report_file}_NC_count \
   ${report_file}_bad_snps_removed \
   ${report_file}_DUPLICATE_SAMPLES \


















