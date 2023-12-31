#03a_occ_wrangling.R
#Author: Ben Millard Martin
#Reviewed by Tessa Rehill 

install.packages("jagsUI")
install.packages("dyplr")

library(tidyverse)
library(jagsUI) #had to manually select packages 
library(here)
library(dplyr)


dat <- read.csv("./Processed_data/eDNA/12s/12s_u/asv/matrix/data12Su_asvmatrix_metadata_nc.csv")


spec <- dat[c(22:667)]                               #select Asv Matrix
spec01 <- as.data.frame(ifelse(spec == 0, 0, 1))     #convert to binary
ASVcount <- as.data.frame(colSums(spec01))           #find number of observations of each ASV
ASVcountNo0s <- filter(ASVcount, ASVcount[1] != 0)   #count of detections by ASV
ASV0count <- filter(ASVcount, ASVcount[1] == 0)      #find ASVs with 0 observations
ASVswith0count <- rownames(ASV0count)
ASV1count <- filter(ASVcount, ASVcount[1] == 1)      #find ASVs with 1 observation (one PCR detection in dataset)

spec[,c(ASVswith0count)] <- NULL                     #remove ASVs with 0 observations from ASV matrix
spec01[,c(ASVswith0count)] <- NULL                   #remove ASVs with 0 observations from ASV matrix

ASV_by_sample <- cbind(dat$sample_name, spec01)      #join with sample name
colnames(ASV_by_sample)[1] <- "sample"               #rename column

#make a list of dataframes, if you get "Error: `n()` must only be used inside dplyr verbs." restart R. 
# There is a conflict with one of the packages from OccupancyModel.R

a1 <- dat[c("sample_name", "site")] %>%
  distinct() %>%
  .[-c(49,53,22,27),] 
a2 <- a1 %>% group_by(site) %>% summarise(length = length(site)) %>% filter(length == 2)
a3 <- a1 %>%filter(site %in% a2$site)
a4 <- ASV_by_sample %>%
  group_by(sample) %>%
  summarise_all(sum) %>%
  filter(sample %in% a3$sample_name) %>%
  merge(a1,., by.x = "sample_name", by.y = "sample", all.x = F, all.y = T) %>%
  dplyr::select(-c("sample_name", "site"))
a5 <-  as.data.frame(ifelse(a4 == 0, 0, 1)) 
ASVcount <- as.data.frame(colSums(a5))           #find number of observations of each ASV
ASVcountNo0s <- filter(ASVcount, ASVcount[1] != 0)   #count of detections by ASV
ASV0count <- filter(ASVcount, ASVcount[1] == 0)      #find ASVs with 0 observations
ASVswith0count <- rownames(ASV0count)
ASV1count <- filter(ASVcount, ASVcount[1] == 1)      #find ASVs with 1 observation (one PCR detection in dataset)

a6 <- a5 %>%
  cbind(a3[c("site")],.)
a6[,c(ASVswith0count)] <- NULL    
ASV_by_sample <- a6 %>%
  rename("sample" = "site")

ASVs <- colnames(ASV_by_sample)
ASVs <- ASVs[-1]
ASVlist <- list()

for(i in ASVs){
  t1 <- dplyr::select(ASV_by_sample, sample, i)
  ASV <- t1 %>% 
    group_by(sample) %>%
    mutate(id = paste0("X", 1:n())) %>%
    spread(id, i)
  ASV$sample <- NULL
  ASVlist[[length(ASVlist)+1]] = ASV
}

ASVlist[1] #check to see that it is formatted properly

save(ASVlist, file="./Scripts/occupancy_modelling/royle_link/scratch/ASVlist_u.RData")
save(ASVs, file="./Scripts/occupancy_modelling/royle_link/scratch/ASVs_u.RData")


