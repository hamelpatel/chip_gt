#!/bin/bash

##########################################################################################################################################
####                                                                                                                                  ####
###                                                                                                                                    ###
##                                                                                                                                      ##
#                          CREATE LIST OF SNP FROM ILLUMINA CSV FILE WHICH MAP TO MULTIPLE LOCATIONS OF THE GENOME			 #
##                                                                                                                                      ##
###                                                                                                                                    ###
####                                                                                                                                  ####
##########################################################################################################################################


MANIFEST=$1

BEADCHIP=$(basename $1 .csv)

GENOME_LOCATION="/scratch/data/ngs_ref_resources_b37/human_g1k_v37_individual_chromosome_fasta/"

CHROMOSOMES="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT"


echo -e "\n>>>> START [run_multi_map_search_on_manifest_csv.sh ${1}]\n"


##
##	CONVERT MANIFEST FILE TO UNIX FORMAT
##

dos2unix ${MANIFEST}

##
##	REMOVE HEADER AND TAIL AND ADD NEW NAME FOR LOOK UPS
##

echo -e ".... Make new annotation file: remove header and ending guff and add new name for look-ups > [${BEADCHIP}.txt] ...\n"

    awk -F "," 'NR > 7 {print $0}' ${BEADCHIP}.csv | grep -v ^00 | grep -v "Controls" | \
            awk -F "," '{print $1"-ilmprb-"$2","$0}' > ${BEADCHIP}.txt

##
##	GET PROBE a ONLY VARIANTS FASTA
##

echo -e ".... Make Fasta File for Variants with single probe sequence (A) only > [${BEADCHIP}.single.probe.A.fasta] ...\n"

    cat ${BEADCHIP}.txt  | sed '1d' | tr ',' '\t' | awk ' $9 !~ /[ATCG]/ ' | \
            awk '{print ">"$1"\n"$7}' > ${BEADCHIP}.single.probe.A.fasta

##
##	GET PROBE A & B VARAINTS FASTA
##

echo -e ".... Make Fasta File for Variants with mulitiple probe sequences (A & B) > [${BEADCHIP}.multi.probe.A.and.B.fasta] ...\n"

    cat ${BEADCHIP}.txt  | sed '1d' | tr ',' '\t' | awk -F "\t" ' $9 ~ /[ATCG]/ ' | \
            awk '{print ">"$1"_ProbeA""\n"$7"\n"">"$1"_ProbeB""\n"$9}' >  ${BEADCHIP}.multi.probe.A.and.B.fasta

##
##	COMBINE FASTA FILES FOR MAPPING
##


echo -e ".... Make Fasta File for All Variants: single and mulitiple probe sequences (A & B) > [${BEADCHIP}.fasta] ...\n"

    cat ${BEADCHIP}.single.probe.A.fasta ${BEADCHIP}.multi.probe.A.and.B.fasta > ${BEADCHIP}.fasta

##
##	BLAT PROBE SEQUENCE AGAINST REF GENOME
##

echo -e ".... Blatting probe.fasta against genome ...\n"

for b in $CHROMOSOMES ;
        do
        echo -e ".... Processing chromosome $b"
	blat ${GENOME_LOCATION}/human_g1k_v37_chr_${b}.fasta \
	${BEADCHIP}.fasta \
     	${BEADCHIP}_probe_seq_chr_${b}.psl ;
        done

##
##	CLEAN ALIGNMENT FILES
##

##      merge and clean blast.psl file. create good match where probe matches back to genome 100% based on:
##      -query length must equal length of query searched
##      -start of matched sequence must start from 0
##      -end of matched sequence must end at query length
##      -q gap and t gap = 0

echo -e ".... extracting perfect match probes ...\n"

for c in $CHROMOSOMES ;
        do
        awk -v good_match=${BEADCHIP}_perfect_matched_probes \
        'BEGIN{OFS="\t"} NR>5 {if($11==$13 && $12=="0" && $1==$11 && $2==0 && $3==0 && $4==0 && $5==0 && $6==0 && $7==0 && $8==0 ) print $10, $14, $11, $16+1, $17 >> good_match}' \
        ${BEADCHIP}_probe_iseq_chr_${c}.psl ;
        done


##
##	EXTRACT MULTI-MAPPING PROBES
##

echo -e ".... creating list of multi-mapping SNPS ...\n"

awk '{print $1}' ${BEADCHIP}_perfect_matched_probes | sort | uniq -c | awk '$1>1' | sort -nr > ${BEADCHIP}_probe_multiple_mapping_list_sorted_count

# keep only column 2 and remove -ilmnprobe

sed s'/-ilmprb-/*/g' ${BEADCHIP}_probe_multiple_mapping_list_sorted_count > ${BEADCHIP}_probe_multiple_mapping_list_sorted_count_temp

cut -f1 -d"*" ${BEADCHIP}_probe_multiple_mapping_list_sorted_count_temp | awk '{print $2}' > ${BEADCHIP}_multimapping_SNPs_to_remove


rm ${BEADCHIP}_probe_multiple_mapping_list_sorted_count_temp







