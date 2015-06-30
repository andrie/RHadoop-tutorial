DROP TABLE IF EXISTS taxi_sample;
CREATE EXTERNAL TABLE taxi_sample(medallion STRING, hack_license STRING, vendor_id STRING, rate_code INT, store_and_fwd_flag STRING, pickup_datetime STRING, dropoff_datetime STRING, passenger_count INT, trip_time_in_secs INT, trip_distance FLOAT, pickup_longitude FLOAT, pickup_latitude FLOAT, dropoff_longitude FLOAT, dropoff_latitude FLOAT) ROW FORMAT
DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '/user/andrie.devries/taxi/sample';
