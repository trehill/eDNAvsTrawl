# trawl_eDNA-
SCRIPTS 


a- corresponds to data where we do NOT employ occupancy modelling, only
   ASVs with zero reads are removed 
b- corresponds to data where we DO employ occupancy modelling, dataset singletons are 
   removed, more conservative 
   
   
FOLDER: data QC 
   
Each folder containst 
	-initial cleaning 
	- b - occupancy modelling 
	- remove field controls 
	- harmonize taxonomy + assign taxonomy 
	- determine detection method of species 
	- dataset curation for analysus 
	
note: eDNA index's are not calculated 

FOLDER: data_analysis 	
	- contains scripts for analysis of community similarity (euler plots)
		traits (length distributions), biomass (boxplots)
		
	
FOLDER: Functions
	- contains function for calculating eDNA index on a taxonomy by sample matrix
	from raw read number
	
FOLDER: Occupancy Modelling 
	- contains files that are output/inputs to occupancy modelling scripts used in 
	dataQCb


