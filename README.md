# To eBike or Not to eBike?
NYC Data Science Academy R Project (CitiBike)
 
The purpose of this study was to evaluate the economic feasibility of riding electric bikes within the NYC CitiBike fleet. The full conclusions can be found written here:
https://nycdatascience.com/blog/student-works/to-ebike-or-not-to-ebike/

The following has been used for the R project, which is being superseded in Python for the capstone

unzip_files.r was used for unzipping files

combine_file.r was used for combining relevant .csv files into one

clean_file.r was used for cleaning the combined .csv file

CitiBike_data/202105-202204-citibike-trip-data.parquet contains all the trip data
from May 2021 through April 2022

CitiBike_data/202206-citibike-stations.parquet contains all CitiBike station locations
up until June 2022

The New York City neighborhoods used to map the locations of their respective stations derive
from a Zillow shapefile available here:
https://www.kaggle.com/datasets/jackcook/neighborhoods-in-new-york

And those from the New Jersey (Hudson County) side have been obtained from shapefiles
available here:
https://catalog.data.gov/dataset/tiger-line-shapefile-2016-state-new-jersey-current-place-state-based

The following Jupiter notebooks have been used in this order to prepare the data for visualization:

CB_Python_Combine_File.ipynb to combine the separate CitiBike .csv files for each month and export to .parquet

CB_Python_Clean_File.ipynb to remove null values, duplicates, and other errata

CB_Python_Feature_Eng_Prelim.ipynb to convert timestamp strings to actual timestamps and extract time data

CB_Python_Geolocation.ipynb to extract district station names, locations, and tag to their district respective boroughs (or state - Hudson County, NJ) and neighborhood (or city - Hoboken or Jersey City)

CB_Python_Feature_Eng_Final.ipynb to normalize coordinates and associated distance and speed calculations and attach station borough and neighborhood associations to the main dataframe to complete the final data file to be used for visualization

Finally, to streamline the whole workflow from the notebooks developed above, the following one has been developed:

CB_Full_Service.ipynb

At this point, all future work for the capstone project, which is derived from this one, shall be found at the following location:
https://github.com/jchatterjee/nycdsa_capstone
