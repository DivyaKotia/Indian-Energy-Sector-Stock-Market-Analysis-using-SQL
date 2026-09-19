CREATE DATABASE IF NOT EXISTS indian_energy_stock_analysis;

USE indian_energy_stock_analysis;

CREATE TABLE raw_stock_data(
	company VARCHAR(100),
    industry VARCHAR(100),
    date DATE,
    open DECIMAL(18,4),
    high DECIMAL(18,4),
    low DECIMAL(18,4),
    close DECIMAL(18,4),
    adj_close DECIMAL(18,4),
    volume BIGINT
);

DESCRIBE raw_stock_data;

CREATE TABLE staging_stock_data (
    company VARCHAR(100),
    industry VARCHAR(100),
    date VARCHAR(20),
    adj_close DECIMAL(18,4),
    close DECIMAL(18,4),
    high DECIMAL(18,4),
    low DECIMAL(18,4),
    open DECIMAL(18,4),
    volume BIGINT
);

# INSERTING THE DATA ENTRIES FROM STAGING TABLE TO THE MAIN RAW DATA TABLE

INSERT INTO raw_stock_data (company, industry, date, open, high, low, close, adj_close, volume)
SELECT company, industry, STR_TO_DATE(date, '%d-%m-%Y') as date, open, high, low, close, adj_close, volume FROM staging_stock_data;
