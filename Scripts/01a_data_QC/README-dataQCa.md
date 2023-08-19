# trawl_eDNA-scripts-dataQCv1

FOLDER: DataQCa

Note: this is data quality control scripts for the analysis WITHOUT occupancy modelling
only zero-read ASVs across entire dataset are removed

01_initial_cleaning script
  goal: initial cleaning of raw data files and creation of key metatada files 

  inputs: 
  	"sequence_table.12S.merged.w_ASV_names.length_var.txt" (I dont know where this file came from (need to ask Anya))
  	"sequence_table.12S.merged.w_ASV_names.length_var.txt" (though this is named the same as above, the folder specifies 12su data)
  	"2018_trawl_eDNA_metadata.csv"
  	"trawl_tow_sample_data.csv"
  	"Nordic_Pearl_Survey_Trawl_Specimen_Log_11_18_20.xlsx"
  	"Trawl_catch_data.csv"

  outputs: 
  	"eDNA_metadata.csv" #striped of CO1 information
  	"data12Se_asvmatrix_metadata_nc.csv" #no controls in this dataset
  	"data12Su_asvmatrix_metadata_nc.csv" #no controls in this dataset 
  	"trawl_metadata.csv"
  	"trawl_catch_sum.csv"
  	"trawl_catch.csv"

notes;
  downloading of 'terra' package fails consistently to install which causes issues 
  in the biogeo package (causes some issues with cleaning of trawl data)

02_PCRdissimilarity95.R
  goal: remove samples where one or more PCR replicates has a distance to the sample 
  centroid outside a 95% confidence interval
  in both 12se and 12su 

  input: 
  	"data12Se_asvmatrix_metadata_nc.csv"
  	"data12su_asvmatrix_metadata_nc.csv_"
  
  output: 
  	no output, gives instead samples that are problems 

Next step would be occupancy modelling or remove singletons across whole dataset
  (this is the procedure for b scripts), instead we will only remove ASVs w/ zero 
  observations

03_zero_observation_removal_.R
  goal: remove all ASVs with no observations in whole dataset

  	input: 
  		"data12Su_asvmatrix_metadata_nc.csv"
  		"data12se_asvmatrix_metadata_nc.csv_"

	output: 
		"data12Se_asvmatrix_nc_zor.csv" #dsr = dataset singletons removed
		"data12Su_asvmatrix_nc_zor.csv" 
	

04_field_control_read_removal.R
  goal: remove contaminants from sample read numbers according to maximum concentration 
  in negative controls

  inputs: 
  "eDNA_metadata.csv"
  "data12se_asvmatrix_nc_zor.csv" 
  "data12su_asvmatrix_nc_zor.csv"

  outputs: 
  "data12Se_asvmatrix_nc_zor_nfc.csv" 
  "data12Su_asvmatrix_nc_zor_nfc.csv"
  

05_LICassignment - 
  goal: assign lowest common taxon (now LIT) to groups, include only in-range species 
  this code fits the cleaned asvs to taxonomy  
  
  note- this code requires lots of manual editing 

  inputs: 
  "data12Se_asvmatrix_nc_zor_nfc_.csv" 
  "eDNA_metadata.csv"
  "MiFish_E_taxonomy_table.12S.NCBI_NT.96sim.LCA_ONLY.txt"
  "MiFish_E_taxonomy_table.12S.NCBI_NT.96sim.txt"
  "MiFish_E_12S_ASV_sequences.length_var.blast.out"
  "data12Su_asvmatrix_nc_zor_nfc_.csv" 
  "MiFish_U_taxonomy_table.12S.NCBI_NT.96sim.LCA_ONLY.txt"
  "MiFish_U_taxonomy_table.12S.NCBI_NT.96si.txt"
  "MiFish_U_12S_ASV_sequences.length_var.blast.out"
  

  outputs: 
   "top10_gbifid_higher.csv" (for 12se + 12su)
   "12setaxonomy.csv" (edited)
   "12sutaxonomy.csv" (edited)
   "taxonomy_groups_12s_eDNA_a_.csv"
   "ASV_taxonomy_12seDNA_a_.csv"
   "taxonomy_groups_12su_eDNA_a_.csv"
   "ASV_taxonomy_12su_eDNA_a_.csv"

06_assign_taxonomy_trawl.R
  goal: assigns cleaned taxonomic name to trawl species through curated key 

  inputs: 
  "trawl_catch_sum.csv"
  "trawl_catch.csv"
  "trawl_taxonomy_clean.csv" (curated key by hand)
  
  outputs: 
  "trawl_sum_clean.csv"
  "trawl_catch_clean"


07_eDNA_index.R
	goal: make eDNA index from eDNA read numbers for 12se and 12su data
	add presence/absence for each 
  
  inputs:
  "eDNA_metadata.csv"
  "data12Se_asvmatrix_nc_zor_nfc_.csv"
  "ASV_taxonomy_12seDNA_a_.csv"
  "data12Su_asvmatrix_nc_zor_nfc_.csv"
  "ASV_taxonomy_12su_eDNA_a_.csv"
	
  outputs: 
  "data12se_asv_index_a.csv"
  "data12se_taxonomy_index_a_.csv"
  "data12su_asv_index_a_.csv"
  "data12su_taxonomy_index_a_.csv"

08_datasets.R 
  goal: makes datasets for analysis 
        merges all eDNA data (12su/12se)
        aggregates to set number 
        takes sum of index per species per set number
        takes sum of weight per species per set number

  inputs: 
   "data12se_taxonomy_index_a_.csv"
  "data12su_taxonomy_index_a_.csv"
  "trawl_metadata.csv"
  "data12Su_asvmatrix_metadata_nc.csv"
  "data12Se_asvmatrix_metadata_nc.csv"
  "trawl_sum_clean.csv" #output of assign tax. trawl 

  outputs: 
	"eDNA_allsets_analysisB.csv" #includes 12se + 12su 
	"trawl_allsets_analysisB.csv"
	"trawlweight_allsets_analysisB.csv"" #includes weight aggregates 

09_detection.R
  goal: make a dataset for analysis on diversity by adding detection 
 		method at gamma, beta and alpha levels 
  
  inputs: 
  	"eDNA_allsets_analysisA"
  	trawl_metadata.csv
  	"trawl_allsets_" includes sets >50m
    "trawlweight_allsets_analysis A" includes sets >50m
  
  outputs: 
	"detections_all_A_.csv_" detections for all sets for analysis A



