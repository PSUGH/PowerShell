# check and prepare the environment
# first chgeck if DuckDB is installed
winget.exe list duckdb.cli
## winget install DuckDB.cli

# check if the PS module is installed
# https://github.com/dfinke/PSDuckDB
Get-Module PSDuckDB -ListAvailable
# Install-Module PSDuckDB -Scope AllUsers -Force -AllowClobber  

# check the commands
Get-Command *Duck*

# Basic commands and operations
psduckdb -Command "select 1 + 1"
psduckdb -Command "select 1 / 0"

# Load data from a CSV file
$csv_file = "C:\temp\duckDB\products.csv"
psduckdb -Command "select * from '$csv_file';" | Format-Table

# read directly from repo
$path = 'https://github.com/Teradata/kylo/raw/refs/heads/master/samples/sample-data/parquet/userdata1.parquet'

$stmt = @"
SELECT country, count(*) as cnt
FROM '$path'
group by country
order by cnt desc;
"@
psduckdb -command $stmt | Format-Table

# Create a table from a CSV file
$stmt = @"
CREATE TABLE userdata AS SELECT * FROM '$path';
select birthdate, email from userdata limit 5;
"@
psduckdb -command $stmt | Format-Table
