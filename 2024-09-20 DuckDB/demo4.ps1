$dbpath = 'C:\temp\duckdb\demo4.db'

$path = 'C:\temp\duckdb\SignInLogs'
$conn = New-DuckDBConnection $dbpath


$import = $path + '\*.json'

$qry = 
@"
Create or replace table signinlogs AS
SELECT * FROM read_json('$import',
columns = {
    status: 'STRUCT(
        errorCode BIGINT,
        failureReason VARCHAR,
        additionalDetails VARCHAR
        )'
},
auto_detect = true,
format = 'array'
);
"@
$conn.sql($qry) | Format-Table

$qry = "
SELECT unnest(status, recursive := true) FROM signinlogs LIMIT 1;"

$conn.sql($qry) 
$conn.close()
