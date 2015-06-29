SELECT substring(pickup_datetime, 12, 2) AS hour, COUNT(*) AS count FROM taxi_sample GROUP BY substring(pickup_datetime, 12, 2);
