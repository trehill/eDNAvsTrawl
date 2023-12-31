#Diversity Analysis 
#Author: Ben MM, Tessa Rehill 
#goal: conduct analysis of nestedness + turnover using Jaccards indices 

#install.packages("lubridate")
#install.packages("lme4")
#install.packages("scales")
#install.packages("AICcmodavg")
#install.packages("MASS")
#install.packages("MuMIn")
#install.packages("performance")
#install.packages("geepack")
#install.packages("gee")
#install.packages("rempsyc")

#Set-Up ####
#load libraries
library(tidyverse)
library(lubridate)
library(here)
library(lme4)
library(scales)
library(vegan)
library(AICcmodavg)
library(MASS)
library(MuMIn)
library(performance)
library(RColorBrewer)
library(geepack)
library(gee)
library(dplyr)
library(rempsyc)


#read in files 
long <- read.csv(here::here("Processed_data",
                            "datasets",
                            "detections_all_A.csv"),
                 head=TRUE)


meta <- read.csv(here::here("Processed_data", 
                            "trawl",
                            "metadata", 
                            "trawl_metadata.csv"),
                 head=TRUE)

#make data long
a1 <- long %>%
  dplyr::select(c("set_number", "LCT", "pabs_trawl", "pabs_eDNA")) %>%
  rename("trawl" = "pabs_trawl","eDNA" = "pabs_eDNA")  %>%
  pivot_longer(!c("set_number", "LCT"), names_to = "method", values_to = "pa") %>%
  mutate(id = paste(set_number, method, sep = "_")) %>%
  dplyr::select(c("id", "pa", "LCT")) %>%
  pivot_wider(names_from = "LCT", values_from = "pa") %>%
  column_to_rownames("id") %>%  
  replace(is.na(.), 0)  

Jac <- vegdist(a1, "jaccard")
#from Baselga https://besjournals.onlinelibrary.wiley.com/doi/10.1111/2041-210X.12388
Jac_turn <- designdist(a1, "2 * pmin(b,c) / (a + 2 * pmin(b,c))", abcd = T)
Jac_nest <- designdist(a1, "((pmax(b,c)-pmin(b,c)) / (a+b+c)) * (a / (a + (2 * pmin(b,c))))", abcd = T)
Sor_turn <- designdist(a1, "pmin(b,c) / (a + pmin(b,c))", abcd = T)
Sor_nest <- designdist(a1, "(pmax(b,c)-pmin(b,c)) / (2*a+b+c) * a / (a + pmin(b,c))", abcd = T)

j <- as.matrix(Jac) %>%
  as.data.frame() %>%
  rownames_to_column("A") %>%
  pivot_longer(!A, names_to = "B", values_to = "V1") %>%
  separate(A, c("lnkA", "methodA"), sep = "_") %>%
  separate(B, c("lnkB", "methodB"), sep = "_") %>%
  mutate(common_lnk = if_else(lnkA == lnkB,"y", "n")) %>%
  mutate(common_method = if_else(methodA == methodB,"y", "n")) %>%
  filter(common_lnk == "y" & common_method == "n") %>%
  dplyr::select(c("lnkA", "V1")) %>%
  distinct() %>%
  rename("set_number" = "lnkA") %>%
  rename("Jac" = "V1")

jt <- as.matrix(Jac_turn) %>%
  as.data.frame() %>%
  rownames_to_column("A") %>%
  pivot_longer(!A, names_to = "B", values_to = "V1") %>%
  separate(A, c("lnkA", "methodA"), sep = "_") %>%
  separate(B, c("lnkB", "methodB"), sep = "_") %>%
  mutate(common_lnk = if_else(lnkA == lnkB,"y", "n")) %>%
  mutate(common_method = if_else(methodA == methodB,"y", "n")) %>%
  filter(common_lnk == "y" & common_method == "n") %>%
  dplyr::select(c("lnkA", "V1")) %>%
  distinct() %>%
  rename("set_number" = "lnkA") %>%
  rename("Jac_turn" = "V1")

jn <- as.matrix(Jac_nest) %>%
  as.data.frame() %>%
  rownames_to_column("A") %>%
  pivot_longer(!A, names_to = "B", values_to = "V1") %>%
  separate(A, c("lnkA", "methodA"), sep = "_") %>%
  separate(B, c("lnkB", "methodB"), sep = "_") %>%
  mutate(common_lnk = if_else(lnkA == lnkB,"y", "n")) %>%
  mutate(common_method = if_else(methodA == methodB,"y", "n")) %>%
  filter(common_lnk == "y" & common_method == "n") %>%
  dplyr::select(c("lnkA", "V1")) %>%
  distinct() %>%
  rename("set_number" = "lnkA") %>%
  rename("Jac_nest" = "V1")

sn <- as.matrix(Sor_nest) %>%
  as.data.frame() %>%
  rownames_to_column("A") %>%
  pivot_longer(!A, names_to = "B", values_to = "V1") %>%
  separate(A, c("lnkA", "methodA"), sep = "_") %>%
  separate(B, c("lnkB", "methodB"), sep = "_") %>%
  mutate(common_lnk = if_else(lnkA == lnkB,"y", "n")) %>%
  mutate(common_method = if_else(methodA == methodB,"y", "n")) %>%
  filter(common_lnk == "y" & common_method == "n") %>%
  dplyr::select(c("lnkA", "V1")) %>%
  distinct() %>%
  rename("set_number" = "lnkA") %>%
  rename("Sor_nest" = "V1")

st <- as.matrix(Sor_turn) %>%
  as.data.frame() %>%
  rownames_to_column("A") %>%
  pivot_longer(!A, names_to = "B", values_to = "V1") %>%
  separate(A, c("lnkA", "methodA"), sep = "_") %>%
  separate(B, c("lnkB", "methodB"), sep = "_") %>%
  mutate(common_lnk = if_else(lnkA == lnkB,"y", "n")) %>%
  mutate(common_method = if_else(methodA == methodB,"y", "n")) %>%
  filter(common_lnk == "y" & common_method == "n") %>%
  dplyr::select(c("lnkA", "V1")) %>%
  distinct() %>%
  rename("set_number" = "lnkA") %>%
  rename("Sor_turn" = "V1")

#put all data frames into list
df_list <- list(j, jt, jn, st, sn)
#merge all data frames in list
beta_metrics <- df_list %>% 
  reduce(full_join, by='set_number')


#it looks like set #7 and #5 share the exact same members (have no dissimilarity since they = 1.00)
data <- beta_metrics

write_csv(data,
          here("Processed_data",
               "datasets",
               "diversity",
               "diversity_indices_all_A.csv")) 




