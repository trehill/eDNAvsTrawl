#Exploring eDNA read index over biomass 

#SET UP ####

#install.packages('geosphere')
#install.packages('gmt')
library(tidyr)
library(tidyverse)
library(here)
library(dplyr)
library(ggplot2)
library(geosphere)
library(gmt)

#function
#this function converts angles to decimal coordinates 
angle2dec <- function(angle) {
  angle <- as.character(angle)
  x <- do.call(rbind, strsplit(angle, split=' '))
  x <- apply(x, 1L, function(y) {
    y <- as.numeric(y)
    y[1] + y[2]/60 + y[3]/3600
  })
  return(x)
}

#read data 
beta_div <- read.csv(here::here("Processed_data",
                                "datasets",
                                "detections_all_B.csv"),
                     head=TRUE)

eDNA_index <- read.csv(here::here("Processed_data",
                                'eDNA',
                                "datasets",
                                "eDNA_allsets_analysisB.csv"),
                     head=TRUE)
eDNA_index<- select(eDNA_index, c('LCT', 'set_number','set_read_index'))

trawl_meta <- read.csv(here::here("Processed_data", 
                                  "trawl",
                                  "metadata",
                                  "trawl_metadata.csv"),
                       head=TRUE)

#only want to look at species PRESENT in eDNA AND trawl 
beta_div <- subset(beta_div, pabs_eDNA == 1) 
beta_div <- subset(beta_div, pabs_trawl == 1)
beta_div <- subset(beta_div, weight_total_kg > 0 ) #and only species that had associated weight measurements

#Determining trawl distance ####
#determine distance of trawl by look at metadata + using function above 
#rename columns
trawl_meta <- trawl_meta %>% 
  rename(lat1 = start_latitude_n,
    lon1 = start_longitude_w,
    lat2 = end_latitude_n,
    lon2 = end_longitude_w)

#select specific columns based on lat/lon
trawl <- select(trawl_meta, c('lat1', 'lon1','lat2', 'lon2', 'set_number'))

#change "." to "' 
trawl <- data.frame(lapply(trawl, function(x) {
  gsub(".", " ", x, fixed=TRUE) }))

#change day, min, sec to degrees
trawl$lat1 <- angle2dec(trawl$lat1)
trawl$lat2 <- angle2dec(trawl$lat2)
trawl$lon1 <- angle2dec(trawl$lon1)
trawl$lon2 <- angle2dec(trawl$lon2)


#Standardize 'biomass' by length ####
#Do this by creating a biomass density
#We will take biomass and divide by length of trawl 

#Determining 'length of trawl'
#extract relevant columns 

trawl_distances <- trawl %>% rowwise() %>% 
  mutate(distance = geodist(lat1, lon1, lat2, lon2, units=c("km")))

#merge to beta div 
data <- merge(trawl_distances, beta_div, by=c('set_number'))

#create new column/variable that is biomass index (biomass(weight)/distance)
data$biomass_index <- data$weight_total_kg/data$distance

#add index
data <- merge(data, eDNA_index)
data<- distinct(data)

#plot without log
plot <- ggplot(data,aes(set_read_index, biomass_index)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE, color="#00AFBB") +
  theme_minimal() +
  labs(x='eDNA read index', y='biomass index',title='Biomass / Read Index') +
  theme(plot.title = element_text(hjust=0.5, size=20, face='bold')) +
  theme_classic()

plot 

#plot with log data

plot <- ggplot(data,aes(set_read_index, biomass_index)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE, color="#00AFBB") +
  theme_minimal() +
  scale_y_continuous(trans='log10')+
  scale_x_continuous(trans='log10') +
  labs(x='DNA read index (log)', y='biomass index log(kg/km)') +
  theme(plot.title = element_text(hjust=0.5, size=20, face='bold')) +
  theme_classic()

plot 


#plot only biomass as logged
plot <- ggplot(data,aes(set_read_index, biomass_index)) +
  geom_point() +
  geom_smooth(method='lm', se=FALSE, color="#00AFBB") +
  theme_minimal() +
  scale_y_continuous(trans='log10')+
  labs(x='eDNA read index', y='biomass index log(kg/km)',title='Biomass / Read Index') +
  theme(plot.title = element_text(hjust=0.5, size=20, face='bold')) +
  theme_classic()

plot 


ggsave("./Outputs/analysis_b/biomass/biomass_index_log.png", 
       plot = plot,
       width = 10, height = 6, units = "in")
