# The purpose of this file is to clean the data from the unified file

# install.packages("data.table")  # Install data.table package
library("data.table")             # Load data.table package for fread
# install.packages("geosphere")   # Install geosphere package
library("geosphere")              # Load geosphere package for distance calculation
# install.packages("arrow")       # Install the Apache arrow package
library(arrow)                    # Load arrow package for reading parquet file

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

# After data has been cleaned, can now import again from a csv file
station_data <- fread("CitiBike_data/citibike-station-data.csv")

# Delete unnecessary columns
# CB_data <- CB_data[, -c(1,5,6,7,8)]

# Make sure all values for docked_bike and classic_bike are the same
CB_Data$rideable_type[CB_Data$rideable_type == "docked_bike"] <- "classic_bike"
# CB_Data <- replace(CB_Data$rideable_type, 
#                    CB_Data$rideable_type == "classic_bike",
#                    "Classic Bike")
# CB_Data <- replace(CB_Data$rideable_type, 
#                    CB_Data$rideable_type == "electric_bike",
#                    "Electric Bike")

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

