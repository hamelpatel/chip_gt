Genotype Calling Pipeline VERSION 2.0
==============================================================================

Instructions for running the Genotyping Pipeline  
This will run Zcall on your post GenomeStudio  
Exome chip data  

**********************

REQUIREMENTS
=============================================================================

1.	Sun Grid Engine  
2.	Zcall  

**********************

RUNNING THE PIPELINE
=============================================================================

1.	Prior to running the pipeline, the genotype data should be processed in GenomeStudio as described by Illumina 			Exome Chip SOP v1.4. Following the SOP will produce the output file required by the pipeline. This SOP can 	be viewed at:

	http://confluence.brc.iop.kcl.ac.uk:8090/display/PUB/Production+Version%3A+Illumina+Exome+Chip+SOP+v1.4

2.	Copy the output file from GenomeStudio into the working directory

3.	Copy the bin folder into a bin directory

4.	Copy Zcall into a local directory

5.	Copy the "exome_chip.workflow.version_2.0.sh" script into the working directory

6.	Copy the Illumina chip manifest into the working directory.

7.	Copy the multi-mapping snp file into the working directory. see https://github.com/KHP-Informatics/illumina-array-protocols
	
8.	Copy the Clinical gender information to working directory. should be in file containing no header, sample ID followed by gender in tab delimited format.

9.	Edit the paths in "exome_chip.workflow.version_2.0.sh" for:

	-	exome_chip_bin = path to the bin folder

	-	zcall_bin = path to folder containing Zcall

	-	working_dir = path to where the output files will be created

	-	manifest_file = file name for illumina manifest file for the chip used for genotyping. The file copied in step 6.	
	
	-	multi_mapping_probes = file name containing SNP ids to remove due to targetting multiple locations of the genome. The file copied in step 7.

	-	Clinical_gender= file name containing clinical gender. The file copied in step 8.

	-	data_path = path to pipeline_input.report file

	-	basename = name of pipeline_inputfile (exclude .report extension here). 

10.	Execute "exome_chip.workflow.version_2.0.sh" bash script


**********************

PIPELINE PROCESS
=============================================================================

1.	Run initial QC on input file - Working on GenomeStudio output file

	-	Remove SNP where call rate is NC for all samples (SNPs which have been zeroed in genomestudio phase)

	-	Remove Multi-mapping SNPs based on SNP ID provided in multi-mapping snp file

	-	Convert SNP IDs conting "SNP" to "rs_temp". (Zcall has issues with SNP IDs contining "SNP")

	-	Rename any duplicate sample IDs to a unique ID. Appends "duplicate_ID_1" to end of duplicate ID. If multiple duplicates, the next duplicate will be labelled "duplicate_ID_2", etc.

	-	Working on only autosomal chromosomes

			-  	plot of missingness
				
			-	Samples with a call rate 0 removed (samples whcih have been zeroed in GenomeStudio phase)
			
			-	call rate calculated for samples and SNPs
			
			- 	SNP with call rate < 0.9 removed

			-       call rate calculated for samples and SNPs

			- 	Samples with call rate < 0.9 removed

                        -       call rate calculated for samples and SNPs

                        -       SNP with call rate < 0.95 removed

                        -       call rate calculated for samples and SNPs

                        -       Samples with call rate < 0.98 removed

			- 	plot of missingness

			- 	List of rare/common SNP IDs created

			-	LD prune
			
			-	Identify related samples (samples not removed, PI_hat > 0.1875)

			-	Identify heterozygote samples (samples not removed, ± 3 S.D)

	
2.	Runing Zcall - Working on GenomeStudio output file

	-	Remove only samples with a call rate below 0.98 (based on samples Ids identified in initial QC stage)

	-	Run Zcall

3.	Run QC on called genotypes

	- 	update all allele coding to Illumina top strand

	-	Rename "rs_temp" IDs back to "SNP"

	- 	Rename "duplicate_ID" back to original ID	

	-	call rate calculated for samples and SNPs
	
	-	Clinical Gender information introduced into PLINK file (duplicate samples gender not updated)

	-	Id gender anomolies where clinical gender states M/F and genetical gender is different (excludes unknown)

4.	Create Summary Report

**********************

OUPUT FILES
=============================================================================


The final output file is in PLINK format and is found within the "FINAL_ZCALL" folder. 


SNP IDs removed due to failing genomestudio stage can be found in "snp_information/SNP_zeroed_in_genomestudio_to_remove"

Samples IDs removed due to call rate below 98% can be found in "sample_information/samples_with_low_callrate_to_exclude"

Duplicate sample IDs (if any) can be found in "sample_information/*_duplicate_sample_id_temp_changes"

Samples to be aware of due to heterozygosity can be found in "sample_information/het_outliers_sample_exclude"

Related samples identified can be found in "sample_information/related_sample_exclude"

Gender missmatches can be found in "sample_information/gender_missmatches"


All processing files for Zcall are located within the "zcall_proccessing" folder.
All sungrid processing files and error logs are located within the "sge_out" folder.
All PLINK QC processing files are located within the "plink_qc_tmp folder".
The main workfow script is located within the "scripts" folder.
The genotype chips manifest and update allele file is located within the "manifest" folder.
The clinical gender used to update the plink files are located within the "clincial_gender" folder.
SNP IDs identified as multi-mapping or problematic during the GenomeStudio stage are located in the "snp_information" folder.



**********************

ERROR CHECKING
=============================================================================

On the command line use “ll *.e*” to view all sun grid engine job errors. If any of these files have data, view the file to see at which command line the error has occurred. It is common to see two error files:



**********************
### Contacts
- Author: Amos Folarin, Hamel Patel, Stephen Newhouse                                    
- Organisation: KCL/SLaM                                     
- Email: <amosfolarin@gmail.com>, <hamel.patel@kcl.ac.uk>, <stephen.j.newhouse@gmail.com>

