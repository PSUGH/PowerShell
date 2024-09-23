$dbpath = 'C:\temp\duckdb\demo3.db'
$conn = New-DuckDBConnection $dbpath
$dir = "C:\temp\duckDB\parquet"
$files = join-path $dir "fhvhv_*.parquet"
$create = @"
CREATE OR REPLACE TABLE rides AS SELECT 
	hvfhs_license_num,
	PULocationID,
	DOLocationID, 
	base_passenger_fare,
	trip_miles
FROM '$files';
"@
$conn.sql($create)

# check the table structure
$desc = "DESCRIBE SELECT * FROM rides;"
$meta = $conn.sql($desc)

# total rows count
$rows = "select count(*) from rides"
$count = $conn.sql($rows)
"Total rides: " + $count.'count_star()'

$qry = @"
    SELECT 
        PULocationID pickup_zone,
        Zone,
        round(sum_miles) total_miles,
        num_rides,
        round(sum_miles/num_rides) avg_miles
    FROM (
        SELECT
            PULocationID, 
            sum(trip_miles) sum_miles, 
            COUNT(*) num_rides
        FROM rides 
        GROUP BY PULocationID
    ) rides JOIN (
        SELECT LocationId, Zone
        FROM 'C:\temp\duckDB\parquet\taxi+_zone_lookup.csv'
    ) zones ON (LocationId = PULocationID);
"@
$rides = $conn.sql($qry)
$rides | ft

$conn.Close()

