#03_zero_observation_removal 
#Author: Tessa Rehill

#goal: remove dataset singleton in 12se and 12su samples

#Set-Up
library(tidyverse)
library(here)
library(dplyr)

#12SU removal ####
dat <- read.csv("./Processed_data/eDNA/12s/12s_u/asv/matrix/data12Su_asvmatrix_metadata_nc.csv") #read data

spec <- dat[c(22:667)]                               #select Asv Matrix (only part of columns)
spec01 <- as.data.frame(ifelse(spec == 0, 0, 1))     #convert to binary (no longer ASV reads, only 0 or 1)
ASVcount <- as.data.frame(colSums(spec01))           #find number of observations of each ASV, how many times the ASV was observed
ASVcountNo0s <- filter(ASVcount, ASVcount[1] != 0)   #count of detections by ASV, excludes ASVs with zero observations
ASV0count <- filter(ASVcount, ASVcount[1] == 0)      #find ASVs with 0 observations
ASVswith0count <- rownames(ASV0count)

spec[,c(ASVswith0count)] <- NULL                     #remove ASVs with 0 observations from ASV matrix

ASV_by_sample <- cbind(dat$sample_name, spec)      #join with sample name
colnames(ASV_by_sample)[1] <- "sample"               #rename column

#write file 
write_csv(ASV_by_sample, 
          here("Processed_data","eDNA","12s", "12s_u", "asv", "matrix", 
               "data12Su_asvmatrix_nc_zor.csv"))

#12SE removal ####
dat <- read.csv("./Processed_data/eDNA/12s/12s_e/asv/matrix/data12Se_asvmatrix_metadata_nc.csv") #read data

spec <- dat[c(22:667)]                               #select Asv Matrix (only part of columns)
spec01 <- as.data.frame(ifelse(spec == 0, 0, 1))     #convert to binary (no longer ASV reads, only 0 or 1)
ASVcount <- as.data.frame(colSums(spec01))           #find number of observations of each ASV, how many times the ASV was observed
ASVcountNo0s <- filter(ASVcount, ASVcount[1] != 0)   #count of detections by ASV, excludes ASVs with zero observations
ASV0count <- filter(ASVcount, ASVcount[1] == 0)      #find ASVs with 0 observations
ASVswith0count <- rownames(ASV0count)

spec[,c(ASVswith0count)] <- NULL                     #remove ASVs with 0 observations from ASV matrix

ASV_by_sample <- cbind(dat$sample_name, spec)      #join with sample name
colnames(ASV_by_sample)[1] <- "sample"               #rename column

#write file 
write_csv(ASV_by_sample, 
          here("Processed_data","eDNA","12s", "12s_e", "asv", "matrix", 
               "data12Se_asvmatrix_nc_zor.csv"))


