#!/bin/sh
#$-S /bin/bash
#$-cwd
#$-V


#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


#------------------------------------------------------------------------
# DESC:
# convertes a GenomeStudio report file to a ped, through intermediate bed file

# USAGE:
# 

# ARGS
# basename: the file root of a genome studio file

#------------------------------------------------------------------------

module add general/python/2.7.10

#args
basename=${1}


echo -e "convertReportToTPED.py -O ${basename} -R ${basename}"
## taken from zCall
convertReportToTPED.py -O ${basename} -R ${basename}


#echo -e "TPED to BED"
#
#plink --noweb --tfile ${basename} --make-bed --out ${basename}; #converting .tped --> .ped requires intermediate .bed file 
#
#
#echo -e "BED to PED"
#
#plink --noweb --bfile ${basename} --recode --out ${basename};
#
##NOTE: becasue you have made the bed file here, this step is duplicated in exome.qc.pipeline.v03.sh remove there /TODO


