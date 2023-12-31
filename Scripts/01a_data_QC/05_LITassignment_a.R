#Taxonomic Assignments 
#Authors: Tessa Rehill and Ben Millard-Martin 
#goal: script to assign taxonomy to ASV based on top-ten BLAST hits. Species are clustered into Lowest Common Taxonomy
#if not to the species level. The known range of the species is considered through FishBase data. 

#read data ####
# assign taxonomy
# create taxa_by_site_survey matrix
# plot some summaries

# packages and data ####

#install.packages("taxize")

library(tidyverse)
library(here)
library(vegan)
library(usedist)
library(taxize)
library(janitor)
library(dplyr)

#LCT assignments for 12se data ####

#read 12se data 

ASVbysite <- read.csv(here::here("Processed_data", 
                                 "eDNA",
                                 "12s",
                                 "12s_e",
                                 "asv",
                                 "matrix",
                                 "data12Se_asvmatrix_nc_zor_nfc.csv"),
                      head=TRUE)
ncol(ASVbysite) #481

sample_data <- read.csv(here::here("Processed_data", 
                                   "eDNA",
                                   "metadata",
                                   "eDNA_metadata.csv"),
                        head=TRUE)


LCA_method <- read.csv(here::here("Raw_data", 
                                  "eDNA",
                                  "12s",
                                  "12s_e",
                                  "MiFish_E_taxonomy_table.12S.NCBI_NT.96sim.LCA_ONLY.txt"),
                       head=TRUE)

best_hit <-  read.csv(here::here("Raw_data", 
                                 "eDNA",
                                 "12s",
                                 "12s_e",
                                 "MiFish_E_taxonomy_table.12S.NCBI_NT.96sim.txt"),
                      head=TRUE)

top10 <- read.delim("Raw_data/eDNA/12s/12s_e/MiFish_E_12S_ASV_sequences.length_var.blast.out",
                    h=TRUE,
                    fill = TRUE) %>%
  `colnames<-`(c("ASV", "subject", "accesion_num", "taxa_ID", "perc_ID", "coverage", "evalue", "bitscore", "source", "taxonomy")) %>%
  as.data.frame() %>%
  na.exclude() %>%
  separate(taxonomy, into = c("kingdom", "phylum", "class", "order", "family", "genus", "species"), sep = " / ") %>%
  filter(class == "Actinopteri" | class == "Chondrichthyes") 


#select ASVs that passed occupancy models
top10_occ <- top10 %>%
  filter(ASV %in% colnames(ASVbysite))

#identify max percent ID for each ASV 
max_ID <- top10_occ %>%
  group_by(ASV) %>%
  summarise(perc_ID = max(perc_ID))


#ASVs where all 10 assignments are equal. means you have to manually blast.
w1 <- top10_occ %>%
  merge(.,max_ID, by = "ASV") %>%
  mutate(match = if_else(perc_ID.x == perc_ID.y, 1, 0)) %>%
  group_by(ASV) %>%
  summarise(top10_equal = sum(match)) %>%
  filter(top10_equal == 10)

w2 <- top10_occ %>%
  filter(ASV %in% w1$ASV)

problemASV <- unique(w2$ASV)
problemASV <- as.data.frame(problemASV)

#write_csv(problemASV, 
#         here("Processed_data","eDNA","12s", "12s_e", "LITassignment",
#               "problemASV_a.csv"))

fix_ASV <- read.csv(here::here("Processed_data", #read in fixed ASV-species combo
                                           "eDNA",
                                           "12s",
                                           "12s_e",
                                           "LITassignment",
                                           "problemASV_a_edited.csv")) #added missing ASVs from end of script

fix_ASV<- select(fix_ASV, c('ASV','species'))

#select taxonomy for max percent ID
f1 <- merge(max_ID, top10_occ, by = c("ASV", "perc_ID"))

# Merge dataframes and update 'species' values
f1<- left_join(f1, fix_ASV, by = 'ASV') %>%
  mutate(species = ifelse(is.na(species.y), species.x, species.y)) %>%
  select(ASV, species, perc_ID)

#taxize #### only run once and turn off with "#" (as below) ###############################

#add new species assignment (from problem ASVs)  to f1
spec_unique <- unique(f1$species)

#check accepted naming and get higher taxonomy
#top10_gbifid_higher <- classification(sci_id = spec_unique,
#                                                db = 'gbif',
#                                                 #give back ID
#                                              return_id = TRUE) %>% #bind them together
#   cbind(.) 

#names(top10_gbifid_higher)[names(top10_gbifid_higher) == 'query'] <- 'ids' #rename query column to ids

#write_csv(top10_gbifid_higher,
#         here("Processed_data",
#             "eDNA",
#               "12s",
#               "12s_e",
#             "LITassignment",
#             "top10_gbifid_higher_a.csv"))

top10_gbifid_higher <- read.csv(here::here("Processed_data",
                                           "eDNA",
                                           "12s",
                                           "12s_e",
                                           "LITassignment",
                                           "top10_gbifid_higher_a.csv"))
# merge with old names
new_taxonomy <- top10_gbifid_higher %>%
  mutate(old_species = spec_unique) %>%
  relocate(old_species, .after = species)

##################################manual editing required on next lines###########################################

write_csv(new_taxonomy,
          here("Processed_data",
               "eDNA",
               "12s",
               "12s_e",
               "LITassignment",
               "12setaxonomy.csv"))

#export and annotate: add "in_range" column in excell and annotate "y" if in 
#northeast pacific or tributaries, "n" if from other oceans (including western pacific)
#search in FishBase
#rename as below

new_taxa <- read.csv(here::here("Processed_data",
                                "eDNA",
                                "12s",
                                "12s_e",
                                "LITassignment",
                                "12setaxonomy_edited.csv"),
                     head=TRUE)  #import annotated taxa


#create dataframe with all top hits and accepted taxonomy 
#select tazonomy for max percent ID
f2 <- merge(f1[c("ASV", "perc_ID", "species")], new_taxa[1:17], by.x = "species", by.y = "ids") %>% #might need to change number inside []
  select(-c("species")) %>%
  rename("species" = "species.y")


#count the numbers of families, genera, and species with equal max percent ID
f3 <- f2 %>%
  group_by(ASV, perc_ID) %>%
  summarise(across(c("family", "genus", "species"), ~ length(unique(.x)))) %>%
  `colnames<-`(c("ASV", "perc_ID", "fam_n", "gen_n", "spec_n"))

#group ASV to groups that need to be collapsed to family or within and genera or within
fam <- filter(f3, gen_n >= 2)
gen <- filter(f3, gen_n == 1 & spec_n > 1)
spec <- filter(f3, spec_n == 1)

#sort out multiple hits within family ####
#list groups where >2 species
fam_tax <- merge(fam, f2, by = c("ASV", "perc_ID")) %>%
  distinct() 

#which groups have multiple species in range
r1 <- fam_tax %>%
  group_by(ASV) %>%
  summarize(n_in_range = sum(in_range == "y"))

r2 <- filter(r1, n_in_range == 1) 
d1 <- filter(fam_tax, ASV %in% r2$ASV) %>%      #ASVs with multiple hits, but only one species assignment in range, complete
  filter(in_range == "y") %>%
  mutate(LCT = species)%>%
  mutate(all_species = species) %>%
  mutate(level = "species") %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]
r3 <- filter(r1, n_in_range > 1)                #when multiple species in range (not our case!)
r4 <- filter(fam_tax, ASV %in% r3$ASV) %>%
  filter(in_range == "y")
r5 <- r4 %>%
  group_by(ASV) %>%
  summarise(p1 = length(unique(genus))) %>%
  filter(p1 == 1)
r6 <- filter(r4, ASV %in% r5$ASV)               #ASVs with multiple species within genera, add to gen_tax below to cluster within genera
r7 <- filter(r4, !ASV %in% r5$ASV)              #ASVs with multiple genera within families, assign grouping manually
r8 <- r7[with(r7, order(ASV, species)), ] %>%
  group_by(ASV, class, order, family, in_range) %>%
  summarise(all_species = paste(species, collapse=", "))

##################################manual editing required on next lines###########################################
r9 <- data.frame(all_species = unique(r8$all_species))                         #table of family groups
#two groups at this level - 
#1) Lipariscus nanus, Paraliparis rosaceus, Rhinoliparis barbulifer - given LIT 
#2) Isopsetta isolepis, Parophrys vetulus, Psettichthys melanostictus
r9$LCT <- c("Liparidae1","Pleuronectidae1")                            #add a group name (in order) for each row in r9
r10 <- merge(r8, r9, by = "all_species") %>%
  mutate(level = "family") %>%
  mutate(genus = LCT) %>%
  mutate(species = LCT) %>%
  distinct()
d2 <- r10 %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]

#merger q4, q5, q6 for table
tab_fam <- merge(r7[c("ASV", "species")], r8[c("ASV", "all_species")], by = "ASV") %>%
  merge(., r9, by = "all_species") %>%
  select(!ASV) %>%
  distinct()

#sort out multiple hits within genera ####
gen_tax <- merge(gen, f2, by = c("ASV", "perc_ID")) %>%
  distinct() %>%
  rbind(.,r6)                                   #add ASVs with multiple species within genera from above
#which groups have multiple species in range
q1 <- gen_tax %>%
  group_by(ASV) %>%
  summarize(n_in_range = sum(in_range == "y"))

q2 <- filter(q1, n_in_range == 1) 
d3 <- filter(gen_tax, ASV %in% q2$ASV) %>%      #ASVs with multiple hits, but only one species assignment in range, complete
  filter(in_range == "y")%>%
  mutate(LCT = species)%>%
  mutate(level = "species")%>%
  mutate(all_species = species) %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]
q3 <- filter(q1, n_in_range > 1)                #when multiple species in range
q4 <- filter(gen_tax, ASV %in% q3$ASV) %>%
  filter(in_range == "y")                       #ASVs with multiple species in region, in a genus, assign to group below
q5 <- q4[with(q4, order(ASV, species)), ] %>%
  group_by(ASV, class, order, family, genus, in_range) %>%
  summarise(all_species = paste(species, collapse=", "))
q6 <- data.frame(all_species = unique(q5$all_species))                         #table of genus groups
##################################manual editing required on next lines########################################### 
#Anoplarchus insignis/purpurescens
#Sebastes caurinus/maliger
#Lepidopsetta bilineata/polyxystra
#Xiphister atropurpureus/mucosus
#Pholis laeta/ornata
#Oncorhynchus keta 
#Sebastes crameri/diploproa

q6$LCT <- c("Anoplarchus insignis/purpurescens", "Sebastes caurinus/maliger", 'Lepidopsetta bilineata/polyxystra',  
            'Pholis laeta/ornata', "Oncorhynchus keta", "Sebastes crameri/diploproa" )         #add a group name (in order) for each row in q6
q7 <- merge(q5, q6, by = "all_species") %>%
  mutate(level = "genus") %>%
  mutate(species = LCT)


d4 <- q7 %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]

# merger q4, q5, q6 for table
tab_gen <- merge(q4[c("ASV", "species")], q5[c("ASV", "all_species")], by = "ASV") %>%
  merge(., q6, by = "all_species") %>%
  select(!ASV) %>%
  distinct()

##################################manual editing MAY BE required on next lines########################################### 
#species level issues: out of range ####

spec_tax <- merge(spec, f2, by = c("ASV", "perc_ID"))%>% 
  distinct()

y1 <- spec_tax[c(1:21)] #changed these brackets from Ben's code... not sure if it will cause issues 

#species out of range 
out_range <-  y1 %>%                              #species outside of range, assign get rid of these ASVs (since they are very improbable)
  filter(in_range != "y")

#these ASVs have 100% matches all of the same species, but this species is out of range,
#these ASVs most probably correspond to these species (below), otherwise we could exclude them all together

#ASV183- Salvelinus malma
#ASV185- Allosmerus elongatus 
#ASV223- Lycodapus mandibularis
#ASV248- Salvelinus malma
#ASV278- Clupea palassi
#ASV319- Atheresthes stomias 
#ASV541- Gadus macrocephalus
#ASV59 - Gadus macrocephalus
#ASV639 -Clupea palassi
#ASV84- Atheresthes stomias 


####
#y2 <- y1 %>%                              #species outside of range, assign taxa by next best hit
#  filter(in_range != "y") %>%
#  mutate(LCT = c("Salvelinus malma", "Allosmerus elongatus", " Lycodapus mandibularis", "Salvelinus malma", "Clupea palassi",
#                 "Atheresthes stomias",  "Gadus macrocephalus", "Gadus macrocephalus",
#                 "Clupea palassi", "Atheresthes stomias"))%>%             #new assignment goes here (between "")
#  mutate(level = c("species")) %>%             #level of assignment goes here (between "") 
#  mutate(in_range = c("y"))%>%         
#  mutate(all_species = LCT)%>%         
 # mutate(species = LCT)

y2 <- y1 %>%                              #species outside of range, remove 
  filter(in_range != "y") %>%
  mutate(LCT = c("LCT not in range"))%>%             #new assignment goes here (between "")
  mutate(level = c("species")) %>%             #level of assignment goes here (between "") 
  mutate(in_range = c("y"))%>%         
  mutate(all_species = LCT)%>%         
 mutate(species = LCT)
y3 <- filter(y2, level == "genus") %>%
  mutate(all_species = species) %>%
  mutate(species = LCT)
y4 <- filter(y2, level == "family") %>%
  mutate(all_species = species) %>%
  mutate(species = species) %>%
  mutate(genus = LCT)
y5 <- filter(y2, level == "species") %>%
  mutate(all_species = species)%>%
  mutate(species = LCT) %>%
  mutate(genus = word(LCT,1)) #extract genus from species name
y6 <- filter(y2, level == "class") %>%
  mutate(all_species = species) %>%
  mutate(species = LCT) %>%
  mutate(genus = LCT) %>%
  mutate(family = LCT) %>%
  mutate(order = LCT) 
y7 <- rbind(y3,y4,y5,y6)      # NOTE some of y3-y6 don't do anything now,but may when we have other ID issues
d5 <- y7 %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]


y8 <- y1 %>%                              #species inside of range, with single hits, or family or genus issues resolved by removing range issues
  filter(in_range == "y") %>%
  .[c("ASV","species", "class", "order", "family", "genus")] %>%
  rbind(.,d1[c("ASV","species", "class", "order", "family", "genus")]) %>%               #add species from family errors that were resolved by removing range issues
  rbind(.,d3[c("ASV","species", "class", "order", "family", "genus")])               #add species from genus errors that were resolved by removing range issues

# species that were assigned to groups for some ASVs but not others
y9 <- rbind(tab_fam, tab_gen) #grouping table #Ben's code doesn't work because we didn't have any family nuances 
y9 <- rbind(tab_gen) #grouping table #doesn't work because we didn't have any family nuances 
y10 <- merge(y8, y9, by = "species", all.x = T) 
y11 <- filter(y10, !is.na(y10$all_species)) %>%       #the ones that slipped through
  mutate(level = "genus")  %>%       #the ones that slipped through
  mutate(species = LCT)                                   #assign manually
y12 <- filter(y10, is.na(y10$all_species)) %>%
  mutate(level = "species") %>%
  mutate(LCT = species) %>%
  mutate(all_species = species)
d6 <- rbind(y12,y11)%>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]

data <- rbind(d6, d5, d4, d2) 

#check that all ASVs are accounted for and not duplicated - they should all be the same
length(data$ASV) #341
length(unique(data$ASV)) #341
length(unique(top10_occ$ASV)) #341

#check which are missing (none are missing)
unique(top10_occ$ASV)[!unique(top10_occ$ASV) %in% unique(data$ASV)] #none! yay!

#filter out LCTs that are not in range 
data <- data[data$LCT != 'LCT not in range', ]


table <- data[c("level", "LCT", "class", "order", "family", "genus", "species", "all_species")] %>%
  distinct()

write_csv(table,
          here("Processed_data",
               "eDNA",
               "12s",
               "12s_e",
               "LITassignment",
               "taxonomy_groups_12s_eDNA_a.csv"))


write_csv(data,
          here("Processed_data",
               "eDNA",
               "12s",
               "12s_e",
               "LITassignment",
               "ASV_taxonomy_12seDNA_a.csv"))


#LCT assignment for 12su ####
ASVbysite <- read.csv(here::here("Processed_data", 
                                 "eDNA",
                                 "12s",
                                 "12s_u",
                                 "asv",
                                 "matrix",
                                 "data12Su_asvmatrix_nc_zor_nfc.csv"),
                      head=TRUE)

ncol(ASVbysite) #538

LCA_method <- read.csv(here::here("Raw_data", 
                                  "eDNA",
                                  "12s",
                                  "12s_u",
                                  "MiFish_U_taxonomy_table.12S.NCBI_NT.96sim.LCA_ONLY.txt"),
                       head=TRUE)

best_hit <-  read.csv(here::here("Raw_data", 
                                 "eDNA",
                                 "12s",
                                 "12s_u",
                                 "MiFish_U_taxonomy_table.12S.NCBI_NT.96sim.txt"),
                      head=TRUE)

top10 <- read.delim("Raw_data/eDNA/12s/12s_u/MiFish_U_12S_ASV_sequences.length_var.blast.out",
                    h=TRUE,
                    fill = TRUE) %>%
  `colnames<-`(c("ASV", "subject", "accesion_num", "taxa_ID", "perc_ID", "coverage", "evalue", "bitscore", "source", "taxonomy")) %>%
  as.data.frame() %>%
  na.exclude() %>%
  separate(taxonomy, into = c("kingdom", "phylum", "class", "order", "family", "genus", "species"), sep = " / ") %>%
  filter(class == "Actinopteri" | class == "Chondrichthyes") 


#select ASVs that passed occupancy models
top10_occ <- top10 %>%
  filter(ASV %in% colnames(ASVbysite))

#identify max percent ID for each ASV 
max_ID <- top10_occ %>%
  group_by(ASV) %>%
  summarise(perc_ID = max(perc_ID))

#ASVs where all 10 assignments are equal. means you have to manually blast.
w1 <- top10_occ %>%
  merge(.,max_ID, by = "ASV") %>%
  mutate(match = if_else(perc_ID.x == perc_ID.y, 1, 0)) %>%
  group_by(ASV) %>%
  summarise(top10_equal = sum(match)) %>%
  filter(top10_equal == 10)

w2 <- top10_occ %>%
  filter(ASV %in% w1$ASV)

problemASV <- unique(w2$ASV)
problemASV <- as.data.frame(problemASV)

#write_csv(problemASV, 
#          here("Processed_data","eDNA","12s", "12s_u", "LITassignment",
#               "problemASV_a.csv"))

#manually BLAST each ASV to determine top 

fix_ASV <- read.csv(here::here("Processed_data",
                               "eDNA",
                               "12s",
                               "12s_u",
                               "LITassignment",
                               "problemASV_a_edited.csv")) #added ASV 218- Sebastes

fix_ASV<- select(fix_ASV, c('ASV','species'))

#select taxonomy for max percent ID
f1 <- merge(max_ID, top10_occ, by = c("ASV", "perc_ID"))

# Merge dataframes and update 'species' values
f1<- left_join(f1, fix_ASV, by = 'ASV') %>%
  mutate(species = ifelse(is.na(species.y), species.x, species.y)) %>%
  select(ASV, species, perc_ID)

#taxize #### only run once and turn off with "#" (as below) ###################
spec_unique <- unique(f1$species)

#check accepted naming and get higher taxonomy
#top10_gbifid_higher <- classification(sci_id = spec_unique,
#                                                 db = 'gbif',
#                                                return_id = TRUE) %>%  #give back ID
#    cbind(.)  #bind them together

#names(top10_gbifid_higher)[names(top10_gbifid_higher) == 'query'] <- 'ids' #rename query column to ids

#write_csv(top10_gbifid_higher,
#         here("Processed_data",
#             "eDNA",
#              "12s",
#              "12s_u",
#            "LITassignment",
#            "top10_gbifid_higher_a.csv"))

top10_gbifid_higher <- read.csv(here::here("Processed_data",
                                           "eDNA",
                                           "12s",
                                           "12s_u",
                                          "LITassignment",
                                          "top10_gbifid_higher_a.csv"))

# merge with old names
new_taxonomy <- top10_gbifid_higher %>%
  mutate(old_species = spec_unique) %>%
  relocate(old_species, .after = species)

##################################manual editing required on next lines###########################################

write_csv(new_taxonomy,
          here("Processed_data",
               "eDNA",
               "12s",
               "12s_u",
               "LITassignment",
               "12sutaxonomy.csv"))

#export and annotate: add "in_range" column in excell and annotate "y" if in range based on FishBase 

new_taxa <- read.csv(here::here("Processed_data",
                                "eDNA",
                                "12s",
                                "12s_u",
                                "LITassignment",
                                "12sutaxonomy_edited.csv"),
                     head=TRUE)  #import annotated taxa

#create dataframe with all top hits and accepted taxonomy 
#select tazonomy for max percent ID
f2 <- merge(f1[c("ASV", "perc_ID", "species")], new_taxa[1:17], by.x = "species", by.y = "ids") %>% #might need to change number inside []
  select(-c("species")) %>%
  rename("species" = "species.y")

#count the numbers of families, genera, and species with equal max percent ID
f3 <- f2 %>%
  group_by(ASV, perc_ID) %>%
  summarise(across(c("family", "genus", "species"), ~ length(unique(.x)))) %>%
  `colnames<-`(c("ASV", "perc_ID", "fam_n", "gen_n", "spec_n"))

#group ASV to groups that need to be collapsed to family or within and genera or within
fam <- filter(f3, gen_n >= 2)
gen <- filter(f3, gen_n == 1 & spec_n > 1)
spec <- filter(f3, spec_n == 1)

#sort out multiple hits within family ####
#list groups where >2 species
fam_tax <- merge(fam, f2, by = c("ASV", "perc_ID")) %>%
  distinct() 

#which groups have multiple species in range
r1 <- fam_tax %>%
  group_by(ASV) %>%
  summarize(n_in_range = sum(in_range == "y"))

r2 <- filter(r1, n_in_range == 1) 
d1 <- filter(fam_tax, ASV %in% r2$ASV) %>%      #ASVs with multiple hits, but only one species assignment in range, complete
  filter(in_range == "y") %>%
  mutate(LCT = species)%>%
  mutate(all_species = species) %>%
  mutate(level = "species") %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]
r3 <- filter(r1, n_in_range > 1)                #when multiple species in range (not our case!)
r4 <- filter(fam_tax, ASV %in% r3$ASV) %>%
  filter(in_range == "y")
r5 <- r4 %>%
  group_by(ASV) %>%
  summarise(p1 = length(unique(genus))) %>%
  filter(p1 == 1)
r6 <- filter(r4, ASV %in% r5$ASV)               #ASVs with multiple species within genera, add to gen_tax below to cluster within genera
r7 <- filter(r4, !ASV %in% r5$ASV)              #ASVs with multiple genera within families, assign grouping manually
r8 <- r7[with(r7, order(ASV, species)), ] %>%
  group_by(ASV, class, order, family, in_range) %>%
  summarise(all_species = paste(species, collapse=", "))

##################################manual editing required on next lines###########################################
r9 <- data.frame(all_species = unique(r8$all_species))                         #table of family groups

#same as 12se: LIT Pleuronectidae1 = Isopsetta isolepis, Parophrys vetulus, Psettichthys melanostictus
r9$LCT <- c("Pleuronectidae1")                            #add a group name (in order) for each row in r9
r10 <- merge(r8, r9, by = "all_species") %>%
  mutate(level = "family") %>%
  mutate(genus = LCT) %>%
  mutate(species = LCT) %>%
  distinct()
d2 <- r10 %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]

#merger q4, q5, q6 for table
tab_fam <- merge(r7[c("ASV", "species")], r8[c("ASV", "all_species")], by = "ASV") %>%
  merge(., r9, by = "all_species") %>%
  select(!ASV) %>%
  distinct()

#sort out multiple hits within genera ####
gen_tax <- merge(gen, f2, by = c("ASV", "perc_ID")) %>%
  distinct() %>%
  rbind(.,r6)                                   #add ASVs with multiple species within genera from above
#which groups have multiple species in range
q1 <- gen_tax %>%
  group_by(ASV) %>%
  summarize(n_in_range = sum(in_range == "y"))

q2 <- filter(q1, n_in_range == 1) 
d3 <- filter(gen_tax, ASV %in% q2$ASV) %>%      #ASVs with multiple hits, but only one species assignment in range, complete
  filter(in_range == "y")%>%
  mutate(LCT = species)%>%
  mutate(level = "species")%>%
  mutate(all_species = species) %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]
q3 <- filter(q1, n_in_range > 1)                #when multiple species in range
q4 <- filter(gen_tax, ASV %in% q3$ASV) %>%
  filter(in_range == "y")                       #ASVs with multiple species in region, in a genus, assign to group below
q5 <- q4[with(q4, order(ASV, species)), ] %>%
  group_by(ASV, class, order, family, genus, in_range) %>%
  summarise(all_species = paste(species, collapse=", "))
q6 <- data.frame(all_species = unique(q5$all_species))                         #table of genus groups

##################################manual editing required on next lines########################################### 
#Liparis dennyi, Liparis fucensis
#Xiphister atropurpureus, Xiphister mucosus -> Xiphister atropurpureus/mucosus (same as 12se group)
#Sebastes caurinus, Sebastes maliger --> Sebastes caurinus/maliger (same as 12se group)
#Oligocottus maculosus, Oligocottus snyderi
#Anoplarchus insignis, Anoplarchus purpurescens
#Sebastes crameri, Sebastes diploproa

q6$LCT <- c("Liparis dennyi/fucensis", "Xiphister atropurpureus/mucosus", 'Sebastes caurinus/maliger', 'Oligocottus maculosus/snyderi', 
            'Anoplarchus insignis/purpurescens', "Sebastes crameri/diploproa")         #add a group name (in order) for each row in q6
q7 <- merge(q5, q6, by = "all_species") %>%
  mutate(level = "genus") %>%
  mutate(species = LCT)


d4 <- q7 %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]

# merger q4, q5, q6 for table
tab_gen <- merge(q4[c("ASV", "species")], q5[c("ASV", "all_species")], by = "ASV") %>%
  merge(., q6, by = "all_species") %>%
  select(!ASV) %>%
  distinct()

##################################manual editing MAY BE required on next lines########################################### 
#species level issues: out of range ####

spec_tax <- merge(spec, f2, by = c("ASV", "perc_ID"))%>% 
  distinct()

y1 <- spec_tax[c(1:21)] #changed these brackets from Ben's code... not sure if it will cause issues 

#species out of range 
out_range <-  y1 %>%                              #species outside of range, assign get rid of these ASVs (since they are very improbable)
  filter(in_range != "y")
###################################################################################################################################################LAST LEFT OFF
#these ASVs have 100% matches all of the same species, but this species is out of range,
#these ASVs most probably correspond to these species (below), otherwise we could exclude them all together

#ASV124- Lycodapus mandibularis
#ASV34- Gadus macrocephalus
#ASV364 - Gadus macrocephalus
#ASV434 - Clupea pallasii
#ASV515 - Gadus macrocephalus
#ASV607 - Gadus macrocephalus
#ASV609 - Salvelinus malma


####
#y2 <- y1 %>%                              #species outside of range, assign taxa by next best hit (even if not top match)
#  filter(in_range != "y") %>%
#  mutate(LCT = c("Lycodapus mandibularis", "Gadus macrocephalus",  " Gadus macrocephalus",
#                  "Clupea pallasii", "Gadus macrocephalus", "Gadus macrocephalus",  "Salvelinus malma"
#                ))%>%             #new assignment goes here (between "")
#  mutate(level = c("species")) %>%             #level of assignment goes here (between "") 
#  mutate(in_range = c("y"))%>%         
#  mutate(all_species = LCT)%>%         
#  mutate(species = LCT)
y2 <- y1 %>%                              #species outside of range, remove 
  filter(in_range != "y") %>%
  mutate(LCT = c("LCT not in range"))%>%             #new assignment goes here (between "")
  mutate(level = c("species")) %>%             #level of assignment goes here (between "") 
  mutate(in_range = c("y"))%>%         
  mutate(all_species = LCT)%>%         
  mutate(species = LCT)

y3 <- filter(y2, level == "genus") %>%
  mutate(all_species = species) %>%
  mutate(species = LCT)
y4 <- filter(y2, level == "family") %>%
  mutate(all_species = species) %>%
  mutate(species = species) %>%
  mutate(genus = LCT)
y5 <- filter(y2, level == "species") %>%
  mutate(all_species = species)%>%
  mutate(species = LCT) %>%
  mutate(genus = word(LCT,1)) #extract genus from species name
y6 <- filter(y2, level == "class") %>%
  mutate(all_species = species) %>%
  mutate(species = LCT) %>%
  mutate(genus = LCT) %>%
  mutate(family = LCT) %>%
  mutate(order = LCT) 
y7 <- rbind(y3,y4,y5,y6)      # NOTE some of y3-y6 don't do anything now,but may when we have other ID issues
d5 <- y7 %>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]


y8 <- y1 %>%                              #species inside of range, with single hits, or family or genus issues resolved by removing range issues
  filter(in_range == "y") %>%
  .[c("ASV","species", "class", "order", "family", "genus")] %>%
  rbind(.,d1[c("ASV","species", "class", "order", "family", "genus")]) %>%               #add species from family errors that were resolved by removing range issues
  rbind(.,d3[c("ASV","species", "class", "order", "family", "genus")])               #add species from genus errors that were resolved by removing range issues

# species that were assigned to groups for some ASVs but not others
y9 <- rbind(tab_fam, tab_gen) #grouping table #Ben's code doesn't work because we didn't have any family nuances 
y9 <- rbind(tab_gen) #grouping table #doesn't work because we didn't have any family nuances 
y10 <- merge(y8, y9, by = "species", all.x = T) 
y11 <- filter(y10, !is.na(y10$all_species)) %>%       #the ones that slipped through
  mutate(level = "genus")  %>%       #the ones that slipped through
  mutate(species = LCT)                                   #assign manually
y12 <- filter(y10, is.na(y10$all_species)) %>%
  mutate(level = "species") %>%
  mutate(LCT = species) %>%
  mutate(all_species = species)
d6 <- rbind(y12,y11)%>%
  .[c("ASV", "level", "LCT", "class", "order", "family", "genus", "species", "all_species")]

data <- rbind(d6, d5, d4, d2) 

#check that all ASVs are accounted for and not duplicated - they should all be the same
length(data$ASV) #396
length(unique(data$ASV)) #396
length(unique(top10_occ$ASV)) #396

#check which are missing (none are missing)
unique(top10_occ$ASV)[!unique(top10_occ$ASV) %in% unique(data$ASV)]

#filter out LCTs that are not in range 
data <- data[data$LCT != 'LCT not in range', ]

table <- data[c("level", "LCT", "class", "order", "family", "genus", "species", "all_species")] %>%
  distinct()

write_csv(table,
          here("Processed_data",
               "eDNA",
               "12s",
               "12s_u",
               "LITassignment",
               "taxonomy_groups_12su_eDNA_a.csv"))


write_csv(data,
          here("Processed_data",
               "eDNA",
               "12s",
               "12s_u",
               "LITassignment",
               "ASV_taxonomy_12su_eDNA_a.csv"))





