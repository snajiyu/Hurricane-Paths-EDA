# Titile: 
# Description : data analysis and visualizations on ibtracs data from 2010-2015.
# Input(s): data file 'ibtracs-2010-2015.csv'
# Output(s): summary data files, plots.
# Author: Najiyullah Sanee
# Date: 10/16/2019


library(readr)
library(ggplot2)
library(maps)
library(lubridate)
library(dplyr)


#vector for ibtracs-2010-2015 data column names
column_names <- c("serial_num", 
                  "season", 
                  "num", 
                  "basin", 
                  "sub_basin", 
                  "name", 
                  "iso_time", 
                  "nature", 
                  "latitude", 
                  "longitude", 
                  "wind", 
                  "press")

#list for ibtracs-2010-2015 data column types
column_types <- list (
       serial_num = col_character(),
       season = col_integer(),
       num = col_character(),
       basin = col_factor(),
       sub_basin = col_character(),
       name = col_character(),
       iso_time = col_character(),
       nature = col_character(),
       latitude = col_double(),
       longitude = col_double(),
       wind = col_double(),
       press = col_double()
)


#load ibtracs-2010-2015 data from working directory data subdirectory
data<- read_csv(file = "data/ibtracs-2010-2015.csv" , 
         na = c("NA", "-999.", "-1.0", "0.0"), 
         col_names = column_names, 
         col_types = column_types, 
         skip = 1
         )


sink(file = "output/data-summary.txt")
summary(data)
sink()



#modifying columns for plot
data$season = as.numeric(data$season)
data$latitude = as.numeric(gsub("^", "", data$latitude))
data$longitude = as.numeric(gsub("^", "", data$longitude))
data$wind = as.numeric(gsub("^", "", data$wind))


#ID by name and season for paths
data$ID = as.factor(paste(data$name, data$season, sep = "."))
data$name = as.factor(data$name)


#all storms trajecotries from 2010-2015, png
png(filename = "images/map-all-storms.png", width= 900, height= 600, pointsize = 20)
ggplot(data, aes(x = longitude, y = latitude, group = ID)) + 
        ggtitle("Hurricane Trajectories 2010-2015") +
        geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), fill= "snow4", colour = "white") +
        geom_path(data = data, aes(group = ID, colour = wind), alpha = 0.5, size = 0.6) + xlim(-175,175) + ylim(-80,80)  + 
        labs(colour= "Wind (knots)") + theme_bw() 
dev.off()

#all storms trajecotries from 2010-2015, pdf
ggplot(data, aes(x = longitude, y = latitude, group = ID)) + 
        ggtitle("Hurricane Trajectories 2010-2015") +
        geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), fill= "snow4", colour = "white") +
        geom_path(data = data, aes(group = ID, colour = wind), alpha = 0.5, size = 0.6) + xlim(-175,175) + ylim(-80,80)  + 
        labs(colour= "Wind (knots)") + theme_bw() 
ggsave("images/map-all-storms.pdf")


#extracting NA and EP basin storms data
na_basin <- data %>% filter(basin == "NA")
ep_basin <- data %>% filter(basin == "EP")
na_ep_basin <- rbind(na_basin, ep_basin)

#storm trajectories for NA and EP basin by years, pdf
ggplot(na_ep_basin, aes(x = longitude, y = latitude, group = ID)) + 
        ggtitle("NA and EP basin trajectories by Year") +
        geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), fill= "snow4", colour = "white") +
        geom_path(data = na_ep_basin, aes(group = ID, colour = wind), alpha = 0.5, size = 0.6) + xlim(-175,0) + ylim (0,80) + 
        labs(colour= "Wind (knots)") + theme_bw() + facet_wrap(~season)
ggsave("images/map-ep-na-storms-by-year.pdf")


#storm trajectories for NA and EP basin by years, png
png(filename = "images/map-ep-na-storms-by-year.png", width= 900, height= 600, pointsize = 20)
ggplot(na_ep_basin, aes(x = longitude, y = latitude, group = ID)) + 
        ggtitle("NA and EP basin trajectories by Year") +
        geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), fill= "snow4", colour = "white") +
        geom_path(data = na_ep_basin, aes(group = ID, colour = wind), alpha = 0.5, size = 0.6) + xlim(-175,0) + ylim (0,80) + 
        labs(colour= "Wind (knots)") + theme_bw() + facet_wrap(~season)
dev.off()


#creating month names for na_ep_basin storms
na_ep_basin <- mutate(na_ep_basin, date_time = ymd_hms(iso_time))
na_ep_basin <- mutate(na_ep_basin, month_str = month(date_time, label = TRUE))



#storm trajectories for NA and EP basin by years, pdf
ggplot(na_ep_basin, aes(x = longitude, y = latitude, group = ID)) + 
        ggtitle("NA and EP basin trajectories by Months") +
        geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), fill= "snow4", colour = "white") +
        geom_path(data = na_ep_basin, aes(group = ID, colour = wind), alpha = 0.5, size = 0.6) + xlim(-175,0) + ylim (0,80) + 
        labs(colour= "Wind (knots)")  + theme_bw() + facet_wrap(~month_str)
ggsave("images/map-ep-na-storms-by-month.pdf")


#storm trajectories for NA and EP basin by years, png
png(filename = "images/map-ep-na-storms-by-month.png", width= 900, height= 600, pointsize = 20)
ggplot(na_ep_basin, aes(x = longitude, y = latitude, group = ID)) + 
        ggtitle("NA and EP basin trajectories by Months") +
        geom_polygon(data = map_data("world"), aes(x = long, y = lat, group = group), fill= "snow4", colour = "white") +
        geom_path(data = na_ep_basin, aes(group = ID, colour = wind), alpha = 0.5, size = 0.6) + xlim(-175,0) + ylim (0,80) + 
        labs(colour= "Wind (knots)") + theme_bw() + facet_wrap(~month_str)
dev.off()
