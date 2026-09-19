SELECT COUNT(*) AS total_records
FROM staging_stock_data;

SELECT *
FROM staging_stock_data
LIMIT 10;

SELECT DISTINCT date
FROM staging_stock_data
LIMIT 10;

# Checking the DATE transformation to Date dataype

SELECT 
	date AS original_date,
    str_to_date(date, "%d-%m-%Y") as converted_date
    FROM staging_stock_data
    LIMIT 10;
    
# DATE RANGE
SELECT
	MIN(str_to_date(date, '%d-%m-%Y')) AS earliest_date,
    MAX(str_to_date(date, '%d-%m-%Y')) AS latest_date
FROM staging_stock_data;

# INVALID DATES
SELECT COUNT(*) AS invalid_dates
FROM staging_stock_data
WHERE str_to_date(date, "%d-%m-%Y") IS NULL;


SELECT COUNT(*) AS raw_records
FROM raw_stock_data;

# Check 1: No. of records in staging_records = No. of records in raw_stock_data
SELECT
    (SELECT COUNT(*) FROM staging_stock_data) AS staging_records,
    (SELECT COUNT(*) FROM raw_stock_data) AS raw_records;
    
# Check 2: Checking the Datatype of 'date' column
DESCRIBE raw_stock_data;

# Check 3: Checking the Date range in raw_stock_data
SELECT
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date
FROM raw_stock_data;

-- --------------------------------------------------------------------- --
# AUDIT 1: NULL VALUE
# Purpose: To identify missing values across all columns

SELECT 
	COUNT(*) - COUNT(company) AS company_nulls,
    COUNT(*) - COUNT(industry) AS industry_nulls,
    COUNT(*) - COUNT(date) AS date_nulls,
    COUNT(*) - COUNT(open) AS open_nulls,
    COUNT(*) - COUNT(high) AS high_nulls,
    COUNT(*) - COUNT(low) AS low_nulls,
    COUNT(*) - COUNT(close) AS close_nulls,
	COUNT(*) - COUNT(adj_close) AS adj_close_nulls,
	COUNT(*) - COUNT(volume) AS volume_nulls
    from raw_stock_data;
-- -------------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --
# AUDIT - 2: DUPLICATE VALUES
# Purpose: To check whether multiple observations exist for the same company on the same date

SELECT company, date, COUNT(*) AS row_count
FROM raw_stock_data
GROUP BY company, date
HAVING COUNT(*) > 1;

-- -------------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --
# AUDIT - 3: BLANK VALUES i.e. empty spaces
# Purpose: To identify blank or whitespaces-only values

SELECT * FROM raw_stock_data
WHERE trim(company) = '' OR trim(industry)= '';

-- -------------------------------------------------------------------------- --

-- -------------------------------------------------------------------------- --
# AUDIT - 4: OHLC Relationships i.e. High >= Open, High >= Close, Low <= Open, Low <= Close, High >= Low

SELECT count(*) FROM raw_stock_data
WHERE high<open OR high<close OR low > open OR low > close OR high < low;
-- --------------------------------------------------------------------------- --

-- --------------------------------------------------------------------------- --
# AUDIT - 5: Validate price and volume values
# Purpose: To check if any impossible values like -ve values of price or volume

SELECT count(*) FROM raw_stock_data
WHERE open <= 0 OR high <= 0 OR low <= 0 OR close <= 0 OR adj_close <= 0 OR volume < 0;

-- -------------------------------------------------------------------- --
# CHECKING IF ANY COMPANY BELONGS TO MULTIPLE INDUSTRIES

SELECT company FROM raw_stock_data
GROUP BY company
HAVING COUNT(DISTINCT industry) > 1;
-- ------------------------------------------------------------------ --

-- ------------------------------------------------------------------ --
# CHECKING WHICH COMPANIES ARE PRESENT AND WHAT IS THEIR DATE COVERAGE

SELECT company, industry, Min(date) as earliest_date, Max(date) as latest_date, count(*) as no_of_observations
FROM raw_stock_data
GROUP BY company, industry; 
-- ------------------------------------------------------------------ --

-- ------------------------------------------------------------------ --
# CHECKING TOTAL HOW MANY COMPANIES ARE CONSIDERED AND HOW MANY BELONGS TO EACH INDUSTRY

SELECT COUNT(DISTINCT Company) as total_companies from raw_stock_data;

SELECT industry, COUNT(DISTINCT company) as no_of_companies FROM raw_stock_data
GROUP BY industry;
-- ------------------------------------------------------------------- --

-- ------------------------------------------------------------------- --
# CHECKING IF ANY INDUSTRIES CONSIST LARGE NO. OF COMPANIES OR ANY POSSIBLE CLASSIFICATION ISSUES

SELECT industry, COUNT(DISTINCT company) as no_of_companies, COUNT(*) AS no_of_observations FROM raw_stock_data
GROUP BY industry
ORDER BY no_of_companies DESC;
-- ------------------------------------------------------------------- --

-- ------------------------------------------------------------------- --
# CHECKING TRADING DATE COVERAGE i.e. NO. OF TRADING DAYS PER COMPANY

SELECT company, industry, COUNT(*) AS trading_days FROM raw_stock_data
GROUP BY company, industry
ORDER BY  trading_days DESC; 
-- ------------------------------------------------------------------- --

-- ------------------------------------------------------------------- --
# CHECKING IF THERE ARE ANY SUSPICIOUS GAPS IN BETWEEN TWO TADING DAYS FOR ANY COMPANIES (usually no gaps should present)

WITH stock_dates AS(
	SELECT company,
			date as recent_date,
			LAG(date) OVER(
				PARTITION BY company
                ORDER BY date
				) AS previous_date
			FROM raw_stock_data
	date_gaps AS(
    SELECT company, 
			recent_date, 
            previous_date,  
            datediff(recent_date, previous_date) AS days_difference
    FROM stock_dates)
)

SELECT company, recent_date, previous_date, days_difference
FROM date_gaps
GROUP BY company, recent_date, previous_date
ORDER BY days_difference DESC;

