# trawl_eDNA-scripts-dataQCv1

FOLDER: DataQCb

Note: this is data quality control scripts for the analysis WITH occupancy modelling 
(whole dataset singleton removal)

01-02 same as analysis a scripts, removed (but still run in analysis b)

01_initial_cleaning ) 
  goal: initial cleaning of raw data files and creation of key metatada files 
  

02_PCRdissimilarity95.R
  goal: remove samples where one or more PCR replicates has a distance to the sample centroid outside a 95% confidence interval


OCCUPANCY MODEL- REMOVAL OF DATASET SINGLETONS 

3a_occ_wrangling_SE_.R
  goal: occupancy modelling on SE data

  	input: data12Se_asvmatrix_metadata_nc.csv

  outputs: 
  	ASVlist_e.RData
  	ASVs_e.RData"
  	
03a_occ_wrangling_SU_.R
  goal: occupancy modelling on SU data 

  	input: data12Su_asvmatrix_metadata_nc.csv

  outputs: 
  	ASVlist_u.RData
  	ASVs_u.RData"

03b_occ_occupancy_model_SE_.R
  goal: occupancy modelling, running the model on SE data

  outputs: 
  	occProb_royallink_e.csv
  	occProb_royallink_e.rds

03b_occ_occupancy_model_SU_.R
  goal: occupancy modelling, running the model on SU data

  outputs: 
  	occProb_royallink_u.csv
  	occProb_royallink_u.rds
  

03c_occ_output_formatting_SE_.R
  goal: formatting outputs of occupancy model on SE data
  
  input: 
  	occProb_royallink_e.csv

  outputs: 
  	occprob_by_sample_e.csv
  	ata12se_asvmatrix_lor_12s_e.csv
  	data12se_asvmatrix_nc_lor.csv

03c_occ_output_formatting_SU_.R
  goal: formatting outputs of occupancy model on SU data 
  
  input: 
  	occProb_royallink_u.csv

  outputs: 
  	ooccprob_by_sample_u.csv
  	data12se_asvmatrix_lor_12s_u.csv
  	data12su_asvmatrix_nc_lor.csv
	
			
04_field_control_read_removal.R
  goal: remove contaminants from sample read numbers according to maximum concentration in negative controls

  inputs: 
  "eDNA_metadata.csv"
  "data12se_asvmatrix_nc_lor.csv" 
  "data12su_asvmatrix_nc_lor.csv"

  outputs: 
  "data12Se_asvmatrix_nc_lor_nfc.csv" 
  "data12Su_asvmatrix_nc_lor_nfc.csv"
  "data12Se_asv_taxonomy_long_nc_lor_nfc.csv"
  


05_LITassignment - modified version of Ben's code 
  goal: assign lowest common taxon (now LIT) to groups, include only in-range species 
  this code fits the cleaned asvs from occupancy models to taxonomy  

  inputs: 
  "data12Se_asvmatrix_nc_lor_nfc.csv" 
  "eDNA_metadata.csv"
  "MiFish_E_taxonomy_table.12S.NCBI_NT.96sim.LCA_ONLY.txt"
  "MiFish_E_taxonomy_table.12S.NCBI_NT.96sim.txt"
  "MiFish_E_12S_ASV_sequences.length_var.blast.out"
  
  "data12Su_asvmatrix_nc_lor_nfc.csv" 
  "MiFish_U_taxonomy_table.12S.NCBI_NT.96sim.LCA_ONLY.txt"
  "MiFish_U_taxonomy_table.12S.NCBI_NT.96si.txt"
  "MiFish_E_12S_ASV_sequences.length_var.blast.out"
  "data12Su_asvmatrix_nc_lor_nfc.csv"

  outputs: 
  "12setaxonomy.csv" -- later edited for species in/out of range to read in "12setaxonomy2.csv"
  "12sutaxonomy.csv" -- later edited for species in/out of range to read in "12sutaxonomy2.csv"
  "taxonomy_groups_12s_eDNA_b_.csv"
  "ASV_taxonomy_12seDNA_b_.csv"
  "top10_gbifid_higher.csv" - for 12se and 12su 
  "taxonomy_groups_12u_eDNA_b_.csv"
  "ASV_taxonomy_12suDNA_b_.csv"
  

06_assign_taxonomy_trawl.R (same as analysis a)
  goal: assigns cleaned taxonomic name to trawl species through curated key 

  inputs: 
  "trawl_catch_sum.csv"
  "trawl_catch.csv"
  "trawl_taxonomy_clean.csv" (curated key by hand)
  
  outputs: 
  "fix_taxonomy 0-3_" interim dataframes that are manually edited to fix names 
  "trawl_sum_clean.csv"
  "trawl_catch_clean"


07_eDNA_index.R
  goal: make ASV matrix with eDNA reads 
  for each sample + query we have eDNA index 
  
  
  inputs:
  edna_index.R
  data12Se_asvmatrix_nc_lor_nfc.csv 
  ASV_taxonomy_12seDNA_b_.csv 
  ASV_taxonomy_12suDNA_b_.csv 

  outputs:
  "data12se_asv_index_b_.csv"
  "data12se_taxonomy_index_b_.csv"
  "data12su_asv_index.csv_b_"
  "data12su_taxonomy_index_b_.csv"

08_datasets.R 
  goal: makes datasets for analysis 
        merges all eDNA data (12su/12se)
        aggregates to set number 
        takes sum of index per species per set number
        takes sum of weight per species per set number

  inputs: 
   "data12se_taxonomy_index_b_.csv"
  "data12su_taxonomy_index_b.csv"
  "trawl_metadata.csv"
  "data12Su_asvmatrix_metadata_nc.csv"
  "data12Se_asvmatrix_metadata_nc.csv"
  "trawl_sum_clean.csv" #output of assign tax. trawl 

  outputs: 
	"eDNA_allsets.csv" #includes 12se + 12su 
	"trawl_allsets.csv"
	"trawl_weight_allsets.csv" #includes weight aggregates 


09_detection.R
  goal: make a dataset for analysis on diversity by adding detection 
 		method at gamma, beta and alpha levels 
  
  inputs: 
  	"eDNA_allsets_"
  	trawl_metadata.csv
  	"trawl_allsets_" includes sets >50m
    "trawlweight_allsets_" includes sets >50m
  
  outputs: 
	"detections_all_A_.csv_" detections for all sets 


