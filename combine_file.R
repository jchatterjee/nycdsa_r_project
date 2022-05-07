# The purpose of this file is to combine the data from the files downloaded from
# the CitiBike website.

library("data.table") # Load data.table package for fread

# CB_202102 <- fread("CitiBike_data/Raw/New_Format/202102-citibike-tripdata.csv")
# CB_202103 <- fread("CitiBike_data/Raw/New_Format/202103-citibike-tripdata.csv")
# CB_202104 <- fread("CitiBike_data/Raw/New_Format/202104-citibike-tripdata.csv")

# Better to cover a full year of CitiBike data for consistency
CB_202105 <- fread("CitiBike_data/Raw/New_Format/202105-citibike-tripdata.csv")
CB_202106 <- fread("CitiBike_data/Raw/New_Format/202106-citibike-tripdata.csv")
CB_202107 <- fread("CitiBike_data/Raw/New_Format/202107-citibike-tripdata.csv")
CB_202108 <- fread("CitiBike_data/Raw/New_Format/202108-citibike-tripdata.csv")
CB_202109 <- fread("CitiBike_data/Raw/New_Format/202109-citibike-tripdata.csv")
CB_202110 <- fread("CitiBike_data/Raw/New_Format/202110-citibike-tripdata.csv")
CB_202111 <- fread("CitiBike_data/Raw/New_Format/202111-citibike-tripdata.csv")
CB_202112 <- fread("CitiBike_data/Raw/New_Format/202112-citibike-tripdata.csv")
CB_202201 <- fread("CitiBike_data/Raw/New_Format/202201-citibike-tripdata.csv")
CB_202202 <- fread("CitiBike_data/Raw/New_Format/202202-citibike-tripdata.csv")
CB_202203 <- fread("CitiBike_data/Raw/New_Format/202203-citibike-tripdata.csv")
CB_202204 <- fread("CitiBike_data/Raw/New_Format/202204-citibike-tripdata.csv")

CB_data = rbind(CB_202105, CB_202106,
                CB_202107, CB_202108, CB_202109, CB_202110, CB_202111,
                CB_202112, CB_202201, CB_202202, CB_202203, CB_202204)

fwrite(CB_data, file = "CitiBike_data/202105-202204-citibike-trip-data.csv")
