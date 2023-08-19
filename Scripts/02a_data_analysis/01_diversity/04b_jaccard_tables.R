#Jaccard Tables + Plots
#goal: visualize jaccard components and format values into a table

#SET-UP ####
#load libraries 
library(tidyr)
library(tidyverse)
library(here)
library(dplyr)
library(rempsyc)

#read data
data3 <- read.csv(here::here("Processed_data",
                             "datasets",
                            "diversity",
                            "diversity_indices_all_A.csv"),
                 head=TRUE)

#table w/ all sets ####
data3$set_number <- as.numeric(data3$set_number) #make set-number numeric instead of character
data3 <- data3 %>% arrange(set_number) #arrange numbers in increasing order 
data3$set_number <- as.character(data3$set_number) #change set-number back to character
colnames(data3) <- c('site','Jaccards','Jaccards Turnover', 'Jaccards Nestedness') #change column names 
data3 <- select(data3, c('site','Jaccards','Jaccards Turnover', 'Jaccards Nestedness')) #select specific columns to be included in table

#make table!
my_table <- nice_table(
  data3[1:16, ], 
  title = c("Table 2", "Diversity Indices Dissimilarities"), 
  note = c("The data was calculated from adapted methods from Baselga & Leprieur (2015)"))

my_table


