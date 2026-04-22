-- ============================================
-- GOLD LAYER - BUSINESS READY DATA
-- ============================================
-- This script creates views on top of Silver layer data.
-- These views are optimized for reporting and analytics.
-- Data is read from Azure Data Lake (Parquet format)

-- Create schema for Gold layer
CREATE SCHEMA gold;

-- ============================================
-- FACT TABLE: Sales Data
-- Source: Silver Layer (cleaned data from Databricks)
-- Purpose: Central table for all sales analysis
-- ============================================

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT *
FROM OPENROWSET(
    BULK 'https://storageaccount.dfs.core.windows.net/silver/sales_pipeline/*.parquet',
    FORMAT = 'PARQUET'
) AS rows;

-- Dimension: Accounts
-- Contains customer/company level information

CREATE OR ALTER VIEW gold.dim_accounts AS
SELECT *
FROM OPENROWSET( -- Note: OPENROWSET is used for serverless querying of Parquet files in Data Lake
    BULK 'https://storageaccount.dfs.core.windows.net/silver/accounts/*.parquet',
    FORMAT = 'PARQUET'
) AS rows;

-- Dimension: Products
-- Contains product details used in sales

CREATE OR ALTER VIEW gold.dim_products AS
SELECT *
FROM OPENROWSET(
    BULK 'https://storageaccount.dfs.core.windows.net/silver/products/*.parquet',
    FORMAT = 'PARQUET'
) AS rows;

-- Dimension: Sales Teams
-- Contains sales agent and regional hierarchy

CREATE OR ALTER VIEW gold.dim_sales_teams AS
SELECT *
FROM OPENROWSET(
    BULK 'https://storageaccount.dfs.core.windows.net/silver/sales_teams/*.parquet',
    FORMAT = 'PARQUET'
) AS rows;


-- ============================================
-- BUSINESS INSIGHTS (AGGREGATED VIEWS)
-- ============================================

-- Insight: Total Revenue by Region
-- Helps identify top-performing regions

CREATE VIEW gold.revenue_by_region AS
SELECT
    st.region,
    SUM(fs.close_value) AS total_revenue
FROM gold.fact_sales fs
JOIN gold.dim_sales_teams st
    ON fs.sales_agent = st.sales_agent
GROUP BY st.region;

-- Insight: Top Products by Revenue
-- Used to identify high-performing products

CREATE VIEW gold.top_products AS
SELECT
    product,
    SUM(close_value) AS total_revenue
FROM gold.fact_sales
GROUP BY product;

-- Insight: Deal Stage Distribution
-- Shows pipeline health (Won, Lost, etc.)

CREATE VIEW gold.deal_stage AS
SELECT
    deal_stage,
    COUNT(*) AS total_deals,
    SUM(close_value) AS total_revenue
FROM gold.fact_sales
GROUP BY deal_stage;

