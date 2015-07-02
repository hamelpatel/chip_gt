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

10..	Execute "exome_chip.workflow.version_2.0.sh" bash script


**********************

PIPELINE PROCESS
=============================================================================

1.	Run QC on input file

	-	Calculate missingness across SNP’s

	-	Calculate Hardy-Weinberg equilibrium 

	-	Calculate missingness across samples

	-	Remove samples with call rate below 98%

	-	Remove SNPs zeroed in during the GenomeStudio stage and multi-mapping SNPs

	-	Identify related samples (samples not removed, PI_hat > 0.1875) 

	-	Identify heterozygote samples (samples not removed, ± 3 S.D)
	
	-	Identify duplicate samples
	
2.	Run Zcall

3.	Run QC on called genotypes

	-	Calculate missingness across SNP’s

	-	Calculate Hardy-Weinberg equilibrium 

	-	Calculate missingness across samples
	
	-	check clinical Gneder against gentical gender and identify any annomolies	

**********************

OUPUT FILES
=============================================================================

Amongst the numerous files created, the majority are Zcall/Opticall processing files. The plink format output files from Opticall and Zcall are:

-	pipeline_inputfile_filt_Opticall_UA.bed

-	pipeline_inputfile_filt_Opticall_UA.bim

-	pipeline_inputfile_filt_Opticall_UA.fam

-	pipeline_inputfile_filt_Zcall_UA.bed

-	pipeline_inputfile_filt_Zcall_UA.bim

-	pipeline_inputfile_filt_Zcall_UA.fam



Other files of interest include:

-	final_sample_callrate_exclude – list of samples with call rate below 98%

-	final_sample_exclude – list of all samples removed prior to Zcall/Opticall processing

-	pipeline_inputfile_plinkQC_01_poor_snp_callrate_exclude – list of SNP’s with call rate below 95%

-	related_sample_exclude – list of samples removed due to relatedness

-	het_outliers_sample_exclude  - list of samples removed due to heterozgosity (file only created if samples 			removed)

-	pipeline_inputfile_filt_Zcalls_UA.frq - Zcall ouput file minor allele frequency (MAF) for each SNP

-	pipeline_inputfile_filt_Zcalls_UA.hwe ¬– Zcall output file Hardy-Weinberg Equilibrium results

-	pipeline_inputfile_filt_Zcalls_UA.imiss – Zcall output file sample missing rate across SNP’s

-	pipeline_inputfile_filt_Zcalls_UA.lmiss – Zcall output file SNP missing rate across samples

-	pipeline_inputfile_filt_Opticall_UA.frq - Opticall output file minor allele frequency (MAF) for each SNP

-	pipeline_inputfile_filt_Opticall_UA.hwe - Opticall output file Hardy-Weinberg Equilibrium results

-	pipeline_inputfile_filt_Opticall_UA.imiss - Opticall output file sample missing rate across SNP’s

-	pipeline_inputfile_filt_Opticall_UA.lmiss - Opticall output file SNP missing rate across samples

-	zcall_v_opticall_sample_diff_counts.txt – difference in Zcall/Opticall genotype calls across samples

-	zcall_v_opticall_snp_diff_counts.txt -  difference in Zcall/Opticall genotype calls across SNP

-	*log -  plink log files for procedures executed in plink.

**********************

ERROR CHECKING
=============================================================================

On the command line use “ll *.e*” to view all sun grid engine job errors. If any of these files have data, view the file to see at which command line the error has occurred. It is common to see two error files:

-	concat-opticall.e1165215

-	opticall2plink.e1165216

both being produced by lack of XY SNPs within the data.



**********************
### Contacts
- Author: Amos Folarin, Hamel Patel, Stephen Newhouse                                    
- Organisation: KCL/SLaM                                     
- Email: <amosfolarin@gmail.com>, <hamel.patel@kcl.ac.uk>, <stephen.j.newhouse@gmail.com>

