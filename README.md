# Indian Energy Sector Stock Market Analysis using SQL
An ongoing SQL-based analysis of historical daily stock market data for Indian energy-sector companies using **MySQL**. The project focuses on building a structured stock-price database, validating and cleaning historical market data, and developing SQL-based analyses to identify trends, trading patterns, data-quality issues, and company-level market behaviour.

> **Project Status:** 🚧 Ongoing — The database design, data cleaning, validation framework, and initial analytical queries have been implemented. Additional analytical modules and insights are being developed.

---

## 1. Project Overview

This project uses historical daily stock market data covering Indian companies operating across different segments of the energy sector.

The analysis works with daily:

* Open price
* High price
* Low price
* Close price
* Trading volume
* Company
* Industry
* Trading date

The project is implemented in **MySQL** and follows a structured workflow:

**Raw Data → Staging → Data Validation & Cleaning → Analytical Queries → Insights**

The objective is to progressively develop a reusable SQL framework for analysing historical stock-market data rather than performing analysis through isolated queries.

---

## 2. Dataset

The dataset contains historical daily stock-market observations for Indian energy-sector companies, covering approximately **2002–2026**.

### Dataset characteristics

| Attribute      | Description             |
| -------------- | ----------------------- |
| Sector         | Indian Energy           |
| Companies      | 25                      |
| Time Period    | Approximately 2002–2026 |
| Frequency      | Daily                   |
| Observations   | 124,482                 |
| Database       | MySQL                   |
| Primary Data   | OHLCV                   |
| Price Fields   | Open, High, Low, Close  |
| Volume         | Daily trading volume    |
| Classification | Company and Industry    |

### Industry Coverage

The dataset covers multiple segments of the Indian energy sector, including:

* Refineries & Marketing
* LPG / CNG / PNG / LNG Suppliers
* Power
* Oil & Gas
* Renewable Energy
* Other energy-related industries represented in the dataset

The industry classification is retained in the database to enable both company-level and industry-level analysis.

---

## 3. Data Structure

The primary market-data structure contains the following fields:

| Column     | Description                              |
| ---------- | ---------------------------------------- |
| `company`  | Company name                             |
| `industry` | Industry classification                  |
| `date`     | Trading date                             |
| `open`     | Opening price                            |
| `high`     | Highest price during the trading session |
| `low`      | Lowest price during the trading session  |
| `close`    | Closing price                            |
| `volume`   | Trading volume                           |

The database structure is designed so that individual companies can be analysed independently while also allowing cross-company and industry-level comparisons.

---

## 4. Database Architecture

The project uses a staged data-processing workflow.

```text
                    ┌─────────────────────┐
                    │    Source Dataset   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │    Raw Stock Data   │
                    │   raw_stock_data    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Staging / Clean   │
                    │        Data         │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Data Validation &   │
                    │ Quality Checks      │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Analytical SQL      │
                    │ Queries              │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Insights & Metrics  │
                    └─────────────────────┘
```

---

# 5. Data Preparation & Cleaning

Before performing analytical queries, the raw stock data is subjected to a series of validation and transformation steps.

## 5.1 Date Transformation

The original date values are transformed into proper MySQL `DATE` values using functions such as:

```sql
STR_TO_DATE()
```

This allows dates to be correctly used for:

* Sorting
* Date arithmetic
* Time-series analysis
* Trading-period calculations
* Window functions

---

## 5.2 NULL Value Checks

The dataset is checked for missing values across important fields.

Example:

```sql
SELECT *
FROM raw_stock_data
WHERE company IS NULL
   OR industry IS NULL
   OR date IS NULL
   OR open IS NULL
   OR high IS NULL
   OR low IS NULL
   OR close IS NULL
   OR volume IS NULL;
```

This helps identify incomplete observations before analysis.

---

## 5.3 Duplicate Record Checks

Duplicate observations are checked using the combination of company and trading date.

```sql
SELECT
    company,
    date,
    COUNT(*) AS record_count
FROM raw_stock_data
GROUP BY company, date
HAVING COUNT(*) > 1;
```

For daily stock data, multiple records for the same company and trading date require investigation because they may distort subsequent calculations.

---

## 5.4 OHLC Validation

The relationship between Open, High, Low and Close prices is validated using the expected OHLC structure.

For each observation:

```text
High ≥ Open
High ≥ Close
High ≥ Low

Low ≤ Open
Low ≤ Close
Low ≤ High
```

These checks help identify potentially erroneous price records.

---

## 5.5 Company and Industry Consistency

Company-level records are examined to ensure that the industry classification remains consistent across the dataset.

This is important because inconsistent classification can affect industry-level aggregation and comparisons.

---

# 6. Trading-Date Validation

One of the analytical data-quality checks implemented in the project is the identification of gaps between consecutive observations for each company.

This is particularly important for daily stock data because the difference between two observations may represent:

* Normal weekends
* Exchange holidays
* Missing market observations
* Missing data in the source dataset

The project uses the SQL `LAG()` window function to compare each trading date with the previous observation.

### Example

```sql
WITH stock_dates AS (
    SELECT
        company,
        date AS recent_date,
        LAG(date) OVER (
            PARTITION BY company
            ORDER BY date
        ) AS previous_date
    FROM raw_stock_data
),

date_gaps AS (
    SELECT
        company,
        recent_date,
        previous_date,
        DATEDIFF(recent_date, previous_date) AS days_difference
    FROM stock_dates
)

SELECT
    company,
    recent_date,
    previous_date,
    days_difference
FROM date_gaps
WHERE days_difference > 1
ORDER BY company, recent_date;
```

This provides a company-level view of gaps between consecutive observations.

The analysis can subsequently be extended to distinguish expected non-trading periods from potentially missing observations.

---

# 7. SQL Techniques Used

The project progressively applies a range of SQL techniques for data preparation and analysis.

### Data Transformation

* `STR_TO_DATE()`
* `CAST()`
* `CONVERT()`
* Date functions

### Data Quality

* `IS NULL`
* `COUNT()`
* `GROUP BY`
* `HAVING`
* Duplicate detection
* Logical validation rules

### Aggregation

* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`
* `COUNT()`

### Conditional Analysis

* `CASE`
* Conditional aggregation

### Time-Series Analysis

* `DATEDIFF()`
* Date arithmetic
* Consecutive-date analysis

### Window Functions

* `LAG()`
* `LEAD()`
* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`

The use of window functions is particularly important for analysing sequential stock-market observations without collapsing the underlying daily records.

---

# 8. Analytical Framework

The project is being developed through multiple analytical layers.

## Layer 1 — Data Quality

Focuses on establishing whether the underlying dataset is suitable for analysis.

Examples:

* Missing values
* Duplicate observations
* Invalid OHLC relationships
* Date formatting
* Trading-date gaps
* Company classification consistency

---

## Layer 2 — Descriptive Stock Analysis

The next layer focuses on understanding the historical behaviour of individual companies.

Potential metrics include:

* Average closing price
* Minimum closing price
* Maximum closing price
* Average trading volume
* Trading-day count
* Price range
* Period-wise price changes

---

## Layer 3 — Return Analysis

The project can calculate daily and period-level price returns from historical closing prices.

For example:

```text
Daily Return =
(Current Close − Previous Close)
÷ Previous Close
× 100
```

The previous closing price can be obtained using:

```sql
LAG(close) OVER (
    PARTITION BY company
    ORDER BY date
)
```

This creates a structured basis for subsequent return and volatility analysis.

---

## Layer 4 — Company Comparison

The database structure allows companies to be compared using common metrics such as:

* Historical price performance
* Trading volume
* Returns
* Volatility
* Trading activity
* Number of observations

These comparisons can be performed across the complete dataset or selected time periods.

---

## Layer 5 — Industry-Level Analysis

Because each company is mapped to an industry classification, the same analytical framework can be extended from company-level analysis to industry-level analysis.

Examples include:

* Average industry closing price
* Industry trading volume
* Industry-level return measures
* Number of companies represented
* Historical industry comparisons

---

# 9. Planned / Ongoing Analysis

The project is intentionally being developed incrementally.

The following areas are part of the ongoing work:

### Stock Returns

* Daily returns
* Monthly returns
* Annual returns
* Cumulative returns

### Volatility

* Daily price volatility
* Rolling volatility
* Period-wise volatility comparisons

### Moving Metrics

* Moving averages
* Rolling returns
* Rolling trading volume

### Drawdown Analysis

* Historical peaks
* Subsequent declines
* Maximum drawdown
* Recovery periods

### Trading Activity

* Volume trends
* Unusual volume observations
* Volume-based comparisons across companies

### Comparative Analysis

* Company-level comparisons
* Industry-level comparisons
* Period-wise performance analysis

### Advanced SQL Analysis

The project will progressively incorporate more advanced SQL techniques, particularly:

* Window functions
* Common Table Expressions (CTEs)
* Nested queries
* Conditional aggregation
* Rolling calculations
* Ranking functions
* Time-series transformations

---

# 10. Key Design Principles

The project follows several principles when developing the analytical workflow.

### 1. Validate Before Analyse

Data-quality checks are performed before using the data for analytical calculations.

### 2. Preserve Raw Data

The raw dataset is retained separately from transformed or analytical tables.

### 3. Use Reproducible SQL

Analytical outputs should be reproducible from the underlying database through SQL queries.

### 4. Analyse at Multiple Levels

The database is structured to support:

```text
Observation
     ↓
Company
     ↓
Industry
     ↓
Overall Dataset
```

### 5. Build Incrementally

New analytical modules are added progressively rather than creating one large SQL script.

---

# 11. Repository Structure

The repository is organised to separate data, SQL scripts, documentation, and analysis.

```text
SQL-STOCK-PRICE-ANALYSIS/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_data_import.sql
│   ├── 03_data_cleaning.sql
│   ├── 04_data_validation.sql
│   ├── 05_date_analysis.sql
│   ├── 06_stock_analysis.sql
│   └── 07_advanced_analysis.sql
│
├── analysis/
│   └── ...
│
├── documentation/
│   └── ...
│
├── README.md
└── .gitignore
```

The exact structure may evolve as additional analytical modules are added.

---

# 12. Example Analytical Questions

The SQL framework is being developed to answer questions such as:

### Data Quality

* Are there duplicate observations?
* Are any required fields missing?
* Are OHLC relationships valid?
* Are there gaps between consecutive trading observations?
* Are company-industry mappings consistent?

### Historical Performance

* How has a company's closing price changed over time?
* What are the minimum and maximum historical prices?
* How many trading observations are available for each company?
* Which periods experienced significant price movements?

### Returns & Risk

* What are the daily returns?
* How does return volatility change over time?
* What are the largest historical declines?
* How long does a stock take to recover from a major decline?

### Trading Activity

* How does trading volume change over time?
* Which periods have unusually high trading activity?
* How does trading activity differ across companies?

### Industry Analysis

* How do companies within the same industry compare?
* How do industry-level metrics change over time?
* How does trading behaviour differ across energy-sector segments?

---

# 13. Data Limitations

The analysis is subject to limitations inherent in historical market data.

These include:

* Historical data quality depends on the original data source.
* Trading-date gaps may represent legitimate market holidays or missing observations and therefore require contextual interpretation.
* Historical prices alone do not capture all corporate actions unless the source data has been appropriately adjusted.
* Company and industry classifications depend on the classification used in the dataset.
* Historical relationships do not necessarily represent future market behaviour.

These limitations are considered when extending the analysis.

---

# 14. Project Status

### Completed

* [x] Database structure
* [x] Raw stock-data table
* [x] Staging workflow
* [x] Date transformation and validation
* [x] NULL-value checks
* [x] Duplicate-record checks
* [x] OHLC validation
* [x] Company/industry consistency checks
* [x] Trading-date coverage analysis
* [x] Consecutive-date gap analysis using `LAG()`
* [x] Initial SQL analytical framework

### In Progress

* [ ] Daily return analysis
* [ ] Period-level return analysis
* [ ] Volatility analysis
* [ ] Rolling metrics
* [ ] Drawdown analysis
* [ ] Trading-volume analysis
* [ ] Company-level comparisons
* [ ] Industry-level comparisons
* [ ] Advanced SQL analytical modules
* [ ] Final documentation and consolidated insights

---

# 15. Future Development

The project will continue to evolve from a data-validation and descriptive analysis framework into a broader historical stock-market analysis system.

Planned development includes:

```text
Data Validation
       ↓
Descriptive Statistics
       ↓
Returns
       ↓
Volatility
       ↓
Rolling Metrics
       ↓
Drawdown
       ↓
Company Comparison
       ↓
Industry Comparison
       ↓
Advanced SQL Analysis
```

The repository will be updated as each analytical component is completed.

---

## 16. Technologies

* **MySQL**
* **SQL**
* Relational database design
* Window functions
* Common Table Expressions (CTEs)
* Time-series analysis
* Data validation and quality checks

---

## 17. Project Status

**🚧 Ongoing Project**

The current repository represents the work completed to date. The analytical framework, SQL queries, and documentation will continue to be expanded as additional stock-market analyses are implemented.
