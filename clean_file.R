# The purpose of this file is to clean the data from the unified file

# install.packages("data.table")  # Install data.table package
library("data.table")             # Load data.table package for fread
# install.packages("geosphere")   # Install geosphere package
library("geosphere")              # Load geosphere package for distance calculation
# install.packages("arrow")       # Install the Apache arrow package
library(arrow)                    # Load arrow package for reading parquet file
library(tidyverse)                # Load tidyverse package

# This part is to install the most updated package for "revgeo" directly 
# from the developer
# Install the devtools package
# install.packages('devtools') 
# Detach the package already installed (if applicable); otherwise installing 
# from github won't work
# detach("package:revgeo", unload = TRUE) 
# library(devtools)
# install_github('mhudecheck/revgeo')
library("revgeo")

# Read the .csv files that meet the latest format for CitiBike rider data
CB_Data <- fread("CitiBike_data/202105-202204-citibike-trip-data.csv")

# Read the .parquet file of station id information
# station_data <- read_parquet("CitiBike_data/202009-stations.parquet")

# After data has been cleaned (manually), can now import again from a csv file
station_data <- fread("CitiBike_data/citibike-station-data.csv")

# Clean the station dataframe again in order to simplify the neighborhood categories:
bronx = c("Bronx County")
station_data$neighborhood[station_data$neighborhood %in% bronx] = "The Bronx"
no_br = c("Bushwick", "Greenpoint", "Williamsburg")
so_br = c("DUMBO", "Bedford-Stuyvesant", "Boerum Hill",  
          "Boerum Hill Historic District", "Brooklyn Heights", "Carroll Gardens",
          "Clinton Hill", "Crown Heights", "Eastern Parkway", "Fort Greene",
          "Gowanus", "Greenwood Heights", "Ocean Hill", "Park Slope",
          "Prospect Heights", "Red Hook", "Sunset Park")
station_data$neighborhood[station_data$neighborhood %in% no_br] = "North Brooklyn"
station_data$neighborhood[station_data$neighborhood %in% so_br] = "South Brooklyn"
lo_ma = c("Battery Park City", "Chinatown", "Civic Center", "Financial District",
          "Hudson Square", "Little Italy", "SoHo", "Two Bridges", "Tribeca")
station_data$neighborhood[station_data$neighborhood %in% lo_ma] = "Lower Manhattan"
station_data$neighborhood[station_data$neighborhood == "Nolan Park"] = "Governors Island"
harlem = c("East Harlem", "Harlem", "Manhattan Community Board 11")
station_data$neighborhood[station_data$neighborhood %in% harlem] = "Harlem"
mid_e = c("Flatiron District", "Gramercy", "Kips Bay", "Midtown East", "Murray Hill", 
          "NoMad", "Rose Hill", "Stuy Town", "Turtle Bay", "Union Square")
station_data$neighborhood[station_data$neighborhood %in% mid_e] = "Midtown East"
mid_w = c("Columbus Circle", "Garment District", "Hell’s Kitchen", "Herald Square",
          "Hudson Yards", "Midtown", "Midtown South", "Midtown West", "Theater District")
station_data$neighborhood[station_data$neighborhood %in% mid_w] = "Midtown West"
ues = c("Carnegie Hill", "Lenox Hill", "Manhattan Community Board 8",
        "Upper East Side", "Yorkville")
station_data$neighborhood[station_data$neighborhood %in% ues] = "Upper East Side"
up_ma = c("Fort George", "Hamilton Heights", "Hudson Heights", "Manhattanville",
          "Morningside Heights", "Sugar Hill", "Washington Heights")
station_data$neighborhood[station_data$neighborhood %in% up_ma] = "Upper Manhattan"
wv = c("Greenwich Village", "Meatpacking District", "Washington Square Village",
       "West Village")
station_data$neighborhood[station_data$neighborhood %in% wv] = "West Village"
rw = c("Fresh Pond Junction", "Ridgewood")
station_data$neighborhood[station_data$neighborhood %in% rw] = "Ridgewood"

# Delete unnecessary columns
CB_Data <- CB_Data[, -c(1, 6, 8)]

# Make sure all values for docked_bike and classic_bike are the same
CB_Data$rideable_type[CB_Data$rideable_type == "docked_bike"] = "classic_bike"
CB_Data$rideable_type[CB_Data$rideable_type == "classic_bike"] = "Classic Bike"
CB_Data$rideable_type[CB_Data$rideable_type == "electric_bike"] = "Electric Bike"

# Calculate actual duration of ride (in minutes) as well as year and month
setDT(CB_Data)[, year := format(as.Date(started_at), "%Y") ]
setDT(CB_Data)[, month := format(as.Date(started_at), "%m") ]
CB_Data$duration = as.numeric(
  difftime(
    CB_Data$ended_at, 
    CB_Data$started_at, 
    units ="mins"
  )
)

# Delete unnecessary columns again
CB_Data <- CB_Data[, -c(2, 3)]

# Figure out the beginning and end destination of the neighborhood and borough
# This will require matching the start and end station names against the data
# frame containing the station information. Since the station ids in the the
# ride data frame and the station data frame do no line up, the exact text strings
# will have to be matched.
for (x in 1:nrow(CB_Data)) {
  sprintf("Repetition: %d", x)
  if (CB_Data$start_station_name[x] %in% station_data$'station name') {
    CB_Data$start_hood[x] = station_data$neighborhood[
      station_data$'station name' == CB_Data$start_station_name[x]]
    CB_Data$start_boro[x] = station_data$boro[
      station_data$'station name' == CB_Data$start_station_name[x]]
  } else {
    CB_Data$start_hood[x] = NA
    CB_Data$start_boro[x] = NA
  }
  sprintf("Start neighborhood is: %s", CB_Data$start_hood[x])
  sprintf("Start borough is: %s", CB_Data$start_boro[x])
  if (CB_Data$end_station_name[x] %in% station_data$'station name') {
    CB_Data$end_hood[x] = station_data$neighborhood[
      station_data$'station name' == CB_Data$end_station_name[x]]
    CB_Data$end_boro[x] = station_data$boro[
      station_data$'station name' == CB_Data$end_station_name[x]]
  } else {
    CB_Data$end_hood[x] = NA
    CB_Data$end_boro[x] = NA
  }
  sprintf("End neighborhood is: %s", CB_Data$end_hood[x])
  sprintf("End borough is: %s", CB_Data$end_boro[x])
}

# Figure out the distances being traveled. Since calculating actual roadmap 
# distance through Google Maps or Bing require use of APIs that cost money 
# and place limitations on daily computations, that process shall be forgone 
# in favor of "as the crow flies", which will provide a rough estimate of 
# travel distance in order to figure out speed.

# Convert meters to miles.
# https://stackoverflow.com/questions/49532911/calculate-distance-longitude-latitude-of-multiple-in-dataframe-r
CB_Data$distance <- 0.000621371 * distHaversine(
  cbind(CB_Data$start_lng, CB_Data$start_lat), 
  cbind(CB_Data$end_lng, CB_Data$end_lat) 
)

