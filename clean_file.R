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
# print("CitiBike trip data import complete!")

# Read the .parquet file of station id information
# station_data <- read_parquet("CitiBike_data/202009-stations.parquet")

# After data has been cleaned (manually), can now import again from a csv file
station_data <- fread("CitiBike_data/citibike-station-data.csv")
# print("CitiBike station data import complete!")

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
# print("CitiBike station data frame cleaned!")

# Delete unnecessary columns
CB_Data <- CB_Data[, -c(1, 6, 8)]

# Make sure all values for docked_bike and classic_bike are the same
CB_Data$rideable_type[CB_Data$rideable_type == "docked_bike"] = "classic_bike"
CB_Data$rideable_type[CB_Data$rideable_type == "classic_bike"] = "Classic Bike"
CB_Data$rideable_type[CB_Data$rideable_type == "electric_bike"] = "Electric Bike"
# print("CitiBike trip data frame cleaned!")

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
# print("CitiBike trip times calculated!")

# Delete unnecessary columns again
CB_Data <- CB_Data[, -c(2, 3)]

# Now is a good time to save the files up until this point
# fwrite(CB_Data, file = "CitiBike_data/202105-202204-citibike-trip-data.csv")
# fwrite(station_data, file = "CitiBike_data/citibike-station-data.csv")

# Here is a convenient resume point
CB_Data <- fread("CitiBike_data/202105-202204-citibike-trip-data.csv")
station_data <- fread("CitiBike_data/citibike-station-data.csv")

# Figure out the beginning and end destination of the neighborhood and borough
# This will require matching the start and end station names against the data
# frame containing the station information. Since the station ids in the the
# ride data frame and the station data frame do no line up, the exact text strings
# will have to be matched.

# WARNING: This process took this user six hours. Consider hosting this script
# over a virtual machine on a cloud served

# Since for loops are pretty slow in R, the relevant columns in the dataframes
# shall be vectorized
CB_start_station <- CB_Data$start_station_name
CB_end_station <- CB_Data$end_station_name
station_name <- station_data$'station name'
station_hood <- station_data$neighborhood
station_boro <- station_data$boro

# Initialize empty vectors for proposed new columns
CB_start_hood = c()
CB_start_boro = c()
CB_end_hood = c()
CB_end_boro = c()

for (x in 1:length(CB_start_station)) {
  print(x)
  if (CB_start_station[x] %in% station_name) {
    CB_start_hood[x] = station_hood[station_name == CB_start_station[x]]
    CB_start_boro[x] = station_boro[station_name == CB_start_station[x]]
  } else {
    CB_start_hood[x] = NA
    CB_start_boro[x] = NA
  }
  print(CB_start_hood[x])
  print(CB_start_boro[x])
  if (CB_end_station[x] %in% station_name) {
    CB_end_hood[x] = station_hood[station_name == CB_end_station[x]]
    CB_end_boro[x] = station_boro[station_name == CB_end_station[x]]
  } else {
    CB_end_hood[x] = NA
    CB_end_boro[x] = NA
  }
  print(CB_end_hood[x])
  print(CB_end_boro[x])
}

# Since that took six hours to run this script, time to save these large vectors
# CB_dest <- data.frame(CB_start_hood, CB_start_boro, CB_end_hood, CB_end_boro)
# fwrite(CB_dest, file = "CitiBike_data/202105-202204-citibike-trip-dests.csv")

# Now the columns can be binded
CB_Data <- cbind(CB_Data, CB_dest)

# Delete unnecessary columns again
# CB_Data <- CB_Data[, -c(2, 3)]

# Clean all kinds of null values for new station or missing bikes
# question = "Prospect Park SW & 16 St"
# hood = "South Brooklyn"
# boro = "Brooklyn"
# CB_Data$CB_start_hood[
#   CB_Data$start_station_name == question] = hood
# CB_Data$CB_start_boro[
#   CB_Data$start_station_name == question] = boro
# CB_Data$CB_end_hood[
#   CB_Data$end_station_name == question] = hood
# CB_Data$CB_end_boro[
#   CB_Data$end_station_name == question] = boro
# question = "Warren St & W Broadway "
# hood = "Lower Manhattan"
# boro = "Manhattan"
# CB_Data$CB_start_hood[
#   CB_Data$start_station_name == question] = hood
# CB_Data$CB_start_boro[
#   CB_Data$start_station_name == question] = boro
# CB_Data$CB_end_hood[
#   CB_Data$end_station_name == question] = hood
# CB_Data$CB_end_boro[
#   CB_Data$end_station_name == question] = boro
# question = "49 St & 31 Ave"
# hood = "Astoria"
# boro = "Queens"
# CB_Data$CB_start_hood[
#   CB_Data$start_station_name == question] = hood
# CB_Data$CB_start_boro[
#   CB_Data$start_station_name == question] = boro
# CB_Data$CB_end_hood[
#   CB_Data$end_station_name == question] = hood
# CB_Data$CB_end_boro[
#   CB_Data$end_station_name == question] = boro
# question = "34 St & 38 Ave"
# hood = "Astoria"
# boro = "Queens"
# CB_Data$CB_start_hood[
#   CB_Data$start_station_name == question] = hood
# CB_Data$CB_start_boro[
#   CB_Data$start_station_name == question] = boro
# CB_Data$CB_end_hood[
#   CB_Data$end_station_name == question] = hood
# CB_Data$CB_end_boro[
#   CB_Data$end_station_name == question] = boro
# question = "49 St & 31 Ave"
# hood = "Astoria"
# boro = "Queens"
# CB_Data$CB_start_hood[
#   CB_Data$start_station_name == question] = hood
# CB_Data$CB_start_boro[
#   CB_Data$start_station_name == question] = boro
# CB_Data$CB_end_hood[
#   CB_Data$end_station_name == question] = hood
# CB_Data$CB_end_boro[
#   CB_Data$end_station_name == question] = boro
# question = "Hazen St & 20 Ave"
# hood = "Astoria"
# boro = "Queens"
# CB_Data$CB_start_hood[
#   CB_Data$start_station_name == question] = hood
# CB_Data$CB_start_boro[
#   CB_Data$start_station_name == question] = boro
# CB_Data$CB_end_hood[
#   CB_Data$end_station_name == question] = hood
# CB_Data$CB_end_boro[
#   CB_Data$end_station_name == question] = boro
# question = "41 St & 4 Ave"
# hood = "South Brooklyn"
# boro = "Brooklyn"
# CB_Data$CB_start_hood[
#   CB_Data$start_station_name == question] = hood
# CB_Data$CB_start_boro[
#   CB_Data$start_station_name == question] = boro
# CB_Data$CB_end_hood[
#   CB_Data$end_station_name == question] = hood
# CB_Data$CB_end_boro[
#   CB_Data$end_station_name == question] = boro
# nulls <- which(is.na(CB_Data), arr.ind=TRUE)
# enulls <- which(is.na(ebikes), arr.ind=TRUE)

# CB_Data$CB_start_hood[CB_Data$start_station_name == ""] = "Unknown"
# CB_Data$CB_end_hood[CB_Data$end_station_name == ""] = "Unknown"
# CB_Data$start_lat[is.na(CB_Data$start_lat)] = "Unknown"
# CB_Data$start_lng[is.na(CB_Data$start_lng)] = "Unknown"
# CB_Data$end_lat[is.na(CB_Data$end_lat)] = "Unknown"
# CB_Data$end_lng[is.na(CB_Data$end_lng)] = "Unknown"
# CB_Data$distance[is.na(CB_Data$distance)] = as.numeric(0)
# CB_Data$start_station_name[CB_Data$start_station_name == ""] = "Unknown"
# CB_Data$end_station_name[CB_Data$end_station_name == ""] = "Unknown"
# nulls <- which(is.na(CB_Data), arr.ind=TRUE)

# For simplicity sake, omit the entries with NA values
# Will have a full refined study later with all null values filled in
CB_simple <- na.omit(CB_Data)
CB_simple <- CB_Data[, -c(4, 5, 6, 7)]

# Just a  minor tweak to the member vs casual column
CB_simple$member_casual[CB_simple$member_casual == "member"] = "Member"
CB_simple$member_casual[CB_simple$member_casual == "casual"] = "Casual"

# Now is a good time to save the simplified filet
fwrite(CB_simple, file = "CitiBike_data/[abr]202105-202204-citibike-trip-data.csv")

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

# Delete unnecessary columns again
# CB_Data <- CB_Data[, -c(2, 3, 4, 5)]
