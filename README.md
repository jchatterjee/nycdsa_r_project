# To eBike or Not to eBike?
## NYC Data Science Academy R Project (CitiBike)
 
<p align="justify">The purpose of this study was to evaluate the economic feasibility of riding electric bikes within the NYC CitiBike fleet. The full conclusions can be found written here:</p>

https://nycdatascience.com/blog/student-works/to-ebike-or-not-to-ebike/

<p align="justify">The following Jupyter notebooks have been used in this order to prepare the data for visualization:</p>

<ol align="justify">
 <li>CB_Python_Combine_File.ipynb to combine the separate CitiBike .csv files for each month and export to .parquet</li>
 <li>CB_Python_Clean_File.ipynb to remove null values, duplicates, and other errata</li>
 <li>CB_Python_Feature_Eng_Prelim.ipynb to convert timestamp strings to actual timestamps and extract time data</li>
 <li>CB_Python_Geolocation.ipynb to extract district station names, locations, and tag to their district respective boroughs (or state - Hudson County, NJ) and neighborhood (or city - Hoboken or Jersey City)</li>
 <li>CB_Python_Feature_Eng_Final.ipynb to normalize coordinates and associated distance and speed calculations and attach station borough and neighborhood associations to the main dataframe to complete the final data file to be used for visualization</li>
</ol>

<p align="justify">Finally, to streamline the whole workflow from the notebooks developed above, the following one has been developed:</p>

<ul>
 <li>CB_Full_Service.ipynb</li>
</ul>

<p align="justify">In addition, a duplicate notebook specific to that of electric bikes has been created to utilize a time frame (basically one month later) that has better data on electric bike usage:</p>

<ul>
 <li>CB_Full_Service-eBike.ipynb</li>
</ul>

<p align="justify">At this point, all future work for the capstone project, which is derived from this one, shall be found at the following location:</p>

https://github.com/jchatterjee/nycdsa_capstone

<p align="justify">The New York City neighborhoods used to map the locations of their respective stations derive from a GeoJSON available here:</p>

https://data.beta.nyc/dataset/pediacities-nyc-neighborhoods/resource/35dd04fb-81b3-479b-a074-a27a37888ce7

<p align="justify">Any other coordinates that could not be grouped within the aforementioned GeoJSON were assumed to be that of Hudson County, NJ and labeled accordingly.</p>

***

<p align="justify">The following has been used for the R project (superseded in Python for the capstone):</p>

<ol align="justify">
 <li>unzip_files.r was used for unzipping files</li>
 <li>combine_file.r was used for combining relevant .csv files into one</li>
 <li>clean_file.r was used for cleaning the combined .csv file</li>
 <li>JChatterjee_R_Project.Rmd was used for creating the visualizations that were used for the original class presentation which has been superseded by the aforementioned blog article</li>
</ol>

<p align="justify">The New York City neighborhoods used to map the locations of their respective stations derive from a Zillow shapefile available here:</p>

https://www.kaggle.com/datasets/jackcook/neighborhoods-in-new-york

<p align="justify">And those from the New Jersey (Hudson County) side have been obtained from shapefiles available here:</p>

https://catalog.data.gov/dataset/tiger-line-shapefile-2016-state-new-jersey-current-place-state-based
