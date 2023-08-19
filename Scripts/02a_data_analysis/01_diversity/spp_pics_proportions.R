#Trying to make a script where photos are 'sized' to a different variable
#this will be to create the Euler plots with 

library(png)
library(ggplot2)
library(ggimage)


#try
df <- read.csv(here::here("Matt", 
                          "practice_count.csv"),
               head=TRUE)

ggplot(df, aes(x, y)) + geom_image(aes(image=folder_path), size=1) 
ggplot(df, aes(x, y)) + geom_image(aes(image=folder_path, size=I(n)))



#real code as follows 
f <- read.csv(here::here("Processed_data", 
                         "datasets",
                         "diversity",
                         "gamma_spp_pics.csv"
                         ),
              head=TRUE)

plot <- ggplot(f, aes(x, y)) + geom_image(aes(image=file), size=0.1) 

plot

#now remove background
plot <- ggplot(f, aes(x, y)) +
  geom_image(aes(image = file, size = I(m))) +
  theme_minimal() +  # Remove the background
  theme(panel.grid = element_blank()) +  # Remove grid lines
  xlim(0, 20) +       # Set x-axis limits
  ylim(0, 35)         # Set y-axis limits
plot

