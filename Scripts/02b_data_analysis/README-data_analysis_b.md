README - data_analysis A

  
FOLDER: Diversity 
This folder contains scripts for comparing community assemblages


01_gamma_diversity.R
  goal: look at species detected by trawl/eDNA across all sites, creates quantitative + 
  qualitative Euler plot 
  
  we also investigate species uniquely in the trawl + see if they are represented in NCBI
    
  inputs: 
  "detections_all_A_.csv"
  "trawl_catch_clean.csv"
  eDNA_allsets_analysisA_.csv"
  
  output: 
  gamma_observations.png 
  gamma_species.png
  gamma_venn.png
  

02_beta_diversity.R
  goal: look at species detected by trawl/eDNA across North and South sites, creates 
  quantitative Euler plots (2 for N, 2 for S)
  
  inputs: 
  "detections_all_A.csv"
  "trawl_metadata.csv"
  "trawl_catch_clean.csv"
  "eDNA_allsets_analysisA_.csv"

  outputs: 
  beta_observations.png
  beta_species.png
  south_venn.png
  north_venn.png
  
  
03_set_diversity.R 
  goal: look at species detected by trawl/eDNA across EACH set,  creates quantitative + 
  qualitative Euler plots (2 per site)
  
  inputs: 
	"detections_all_A.csv"

  
  outputs:
  alpha_observation.png
  

04_Jaccards_analyses.R
  goal: calculate Jaccard indices
  
  inputs: 
  "detections_all_A_.csv"
  "trawl_metadata.csv"
  
  outputs: 
  "diversity_indices_all_A_.csv"


  
04b_Jaccard_table.R
	goal: visualize jaccard components and format values into a table

	input: 
	"diversity_indices_all.csv"
	
	output: 
	tables of dissimilarities 
	
05_species_count
	goal: counts occurence of species in whole dataset (eventually will be phylopic code)
	create incidence boxplot across methods 
	gives species count in north and south regions and overlap 
  
  inputs: 
   "detections_all_A.csv"
   "trawl_metadata.csv"
   
   outputs: 
	"spp_count_A.csv"
	"gamma_spp_count_A.csv"
	gamma_incidence_box.png #boxplot of species incidence across eDNA/trawl/both


FOLDER: Traits 

  
01_lengthconversions.R
	goal: convert fork length to total length for species caught in trawl 
	
	inputs:
	"trawl_catch_clean.csv"
	
	outputs: 
	"length_conversions.csv" 

02_max_length_.R 
  goal: make length distribution graphs from maximum spp lengths (sourced from FishBase)
  
  inputs: 
  "detections_all_A.csv"
  "traitdatabase.csv" curated trait database by hand by searching FishBase 
  		(eventually could write script "trait_collection" to do this with code )
   "length_conversions.csv"
   
   outputs: 
   "ind_length_his.png" - histogram of individual species length 
   "length.png" - density plot of ind. + max species lengths 
   "trawleDNA_density.png" - density plot of eDNA + trawl ridges
   "trawl_edna_2.png" - density plot of eDNA + trawl + both ridges
   "max_length_density.png" - density plot all on same line w/ both 
   "length_bymethod_stack.png" - stacked density plot 
   
03_synoptic_length.R
	goal: use synoptic botton trawl datasets from around Van. Island to produce
	mean lengths of species + add this to trait database 
	
	inputs: 
	Synoptic trawl length data: 
	WCVI_biology.cs
	SOG_biology.csv
	QCS_biology.csv
	WCHG_biology.csv
	HS_biology.csv
	"detections_all_A.csv"
			
			
		detections_all_A_.csv
		traitdatabase.csv
	
	outputs: 
		traits_mean_lengths_A_.csv #trait db with mean lengths from synoptic trawl data 
		same plots as 02_length.R but using more representative lenght data 

03a_synoptic_plots 
	goal: plot length distributions using mean lengths (instead of maximum spp lengths)
	t-test analysis of NO significant difference in mean length of all spp in trawl vs. 
	eDNA 

	inputs: 
	"traits_mean_lengths_A_.csv"
	"detections_all_A_.csv"
	"length_conversions.csv"
	
	outputs: 
	synop_eDNAtrawl_density.png - all eDNA, all trawl 
	all_length_dist_synop.png - trawl indv. only trawl, only eDNA, both 
	trawl_edna_2_synop.png
	max_length_density.png
	
04_habitat.R
	goal: visualize the habitats patterns of detections using alluvia plots 

	
	inputs: 
	"detections_all_A_.csv"
	"traitdatabase.csv"
	
	outputs: 
	habitat_alluvia.png"
	habitat_alluvia_spp.png
	
	
FOLDER: Index 

01_index.R  (we do not explore read index / biomass relationship)
	goal: exploring eDNA read index over biomass 
	
	inputs: 
	"detections_all_A.csv
	"trawl_metadata.csv
	
	outputs: 
	biomass_index_log.png

biomass.R 
	goal: compare biomass relationship between trawl + eDNA, perform t-test
	
	inputs: 
	"detections_all_A.csv"
	"trawl_metadata.csv"
	
	outputs: 
	lat_lon_all.csv" #latitude and longitude for all sets
	"biomass_all.csv"
	biomass_box_all_.png"
	
mean_biomass.R
	goal: calculates the mean biomass per spp, and creates euler plot for data visualization

	
	inputs 
	"biomass_all_.csv"
	
	outputs:
	"species_biomass_sum_all_.csv"
	"species_biomass_all.csv"
	"eulerbiomass_all.png"


FOLDER: PCoA
Contains scripts to run Principle Coordination Analysis 


PCoA_samples.R
	points are samples 
	
	goal: PCoA where each point is a sample, either eDNA or trawl and either N or S 
		- formatting species matrix data
		- formatting metadata (standardize across trawl + eDNA)
		- make presence/absence matrix 
		- make sample matrix 
		- create phyloseq object
		- plot 
	
	inputs: 
		"detections_all.csv"
		"trawl_metadata.csv"
		"eDNA_metadata.csv"

	outputs: 
		PCoA1.png
		PCoA_panel1.png
		PCoA_panel2.png

		
FOLDER: Accumulation Curves

accumulation_curves.R
	goal: create spp accumulation curves for eDNA, trawl and across methods
	uses iNEXT package 
	
	inputs: 
	"detections_all_A_.csv"
	
	outputs: 	
	curve_all.png 
	curve_trawl.png
	curve_eDNA.png
	curve_all_final.png
	
	

  