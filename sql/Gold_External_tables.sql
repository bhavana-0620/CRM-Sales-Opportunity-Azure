-- ============================================
-- GOLD LAYER STORAGE (EXTERNAL TABLE SETUP)
-- ============================================
-- This script defines external storage for Gold layer data
-- in Azure Data Lake using Synapse Serverless SQL.
--
-- NOTE:
-- Credentials are managed securely (keys not exposed).
-- Data is stored in Parquet format for efficient querying.
-- This uses CETAS (Create External Table As Select)
-- to persist Gold layer data into Data Lake.
--
-- This helps:
-- - Avoid repeated computation
-- - Improve query performance
-- - Enable direct consumption by reporting tools

CREATE DATABASE SCOPED CREDENTIAL my_creds
WITH
    IDENTITY = 'Managed Identity';

-- Architecture:
-- Bronze → Raw data (ADF)
-- Silver → Cleaned data (Databricks)
-- Gold → Business-ready data (Synapse SQL)

CREATE EXTERNAL DATA SOURCE source_silver
WITH (
    LOCATION = 'https://storageaccount.dfs.core.windows.net/silver',
    CREDENTIAL = my_creds
);

-- Create External Data Source
-- Defines connection to Gold container in Data Lake

CREATE EXTERNAL DATA SOURCE source_gold
WITH (
    LOCATION = 'https://storageaccount.dfs.core.windows.net/gold',
    CREDENTIAL = my_creds


);

-- Define File Format
-- Parquet format is used for optimized storage and performance

CREATE EXTERNAL FILE FORMAT format_parquet
WITH
(
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)

-- ============================================
-- CREATE GOLD EXTERNAL TABLE
-- ============================================
-- This creates a physical dataset in Data Lake (Gold layer)
-- using transformed data from fact_sales view.
--
-- Purpose:
-- - Store aggregated/clean data
-- - Improve performance for reporting tools like Power BI

CREATE EXTERNAL TABLE gold.sales
WITH(
    LOCATION = 'sales',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
) AS
SELECT * from gold.fact_sales


