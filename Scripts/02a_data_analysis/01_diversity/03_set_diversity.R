#Explore Alpha Diversity 

#SET-UP ####
#load libraries 
library(eulerr)
library(ggplot2)
library(tidyr)
library(tidyverse)
library(ggvenn)
library(here)
library(dplyr)

#read in files 
data <- read.csv(here::here("Processed_data", 
                            "datasets",
                            "detections_all_A.csv"),
                 head=TRUE)

#this kind of worked but we want them to overlap 
data_long <- select(data, c('LCT', 'set_number', 'pabs_trawl', 'pabs_eDNA'))

#we want to change all p_abs_trawl/edna 1 = true, 0 = false
data_long$pabs_trawl<-ifelse(data_long$pabs_trawl=="1",TRUE,FALSE)
data_long$pabs_eDNA<-ifelse(data_long$pabs_eDNA=="1",TRUE,FALSE)

#rename pabs variables 
data_long <- data_long %>% 
  rename(trawl = pabs_trawl, #rename pabs variables 
         eDNA = pabs_eDNA) %>% 
  select(-c('LCT')) #remove LCT

#give set_numbers 'level's in order of increasing sets
data_long$set_number <- as.character(data_long$set_number)
data_long$set_number = factor(data_long$set_number, levels = c('1', '2', '3','4', '5','6',
                                                               '7','8','9','10','11','12',
                                                               '13','14','15','16'))



plot <- plot(euler(data_long, by = list(set_number)), legend = TRUE, fills = c("#5491cf","#FCC442","#00AFBB"))
plot 

ggsave("./Outputs/analysis_a/diversity/alpha_species.png", 
       plot = plot,
       width = 12, height = 2, units = "in")

#give set_numbers 'level's in order of increasing depth difference between sets 
data_long$set_number <- as.character(data_long$set_number)

data_long$set_number <- factor(data_long$set_number,levels = 
                                c("1", "2", "5", "10",'12','3','9','13','4','7','8','16','14','11','15','6'))


plot <- plot(euler(data_long, by = list(set_number)), legend = TRUE, fills = c("#5491cf","#FCC442","#00AFBB"))
plot 

ggsave("./Outputs/analysis_a/diversity/alpha_depthdiff.png", 
       plot = plot,
       width = 12, height = 2, units = "in")

#Quantifying overlap at the set level 
data <- read.csv(here::here("Processed_data", 
                            "datasets",
                            "detections_all_A.csv"),
                 head=TRUE)

# Group by 'set_number' and 'gamma_detection_method', then summarize
summary_df <- data %>%
  group_by(set_number, gamma_detection_method) %>%
  summarise(detections = n()) %>%
  pivot_wider(names_from = gamma_detection_method, values_from = detections, values_fill = 0)

colnames(summary_df) <- c('set','both','eDNA', 'trawl') #rename 

summary_df$total <- summary_df$eDNA+ summary_df$both + summary_df$trawl
summary_df$eDNA_all <- summary_df$eDNA+ summary_df$both 

summary_df$eDNA_overlap <- (summary_df$eDNA_all/summary_df$total)*100

mean(summary_df$eDNA_overlap) #98%

