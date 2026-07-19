--SELECT DB_NAME() AS CurrentDatabase;

--USE ChurnAnalysis;
--GO
--SELECT TOP 10 *
--FROM dbo.customer_churn_1M; ctrl + k and then ctril +c

--SELECT COUNT(*) as total_rows
--FROM dbo.customer_churn_1M;

--EXEC sp_help 'dbo.customer_churn_1M';  -- this is stored procedure sp_help which helps us to know about the database and tables and explore it.
-- so we have 32 columns and 1M rows


--SELECT
--    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS MissingAge
--FROM dbo.customer_churn_1M; -- used to check if there are any null values in age column


--DECLARE @sql NVARCHAR(MAX) = '';

--SELECT @sql = @sql +
--'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
--        COUNT(*) AS TotalRows,
--        SUM(CASE WHEN [' + COLUMN_NAME + '] IS NULL THEN 1 ELSE 0 END) AS MissingValues
--FROM dbo.customer_churn_1M
--UNION ALL
--'
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'customer_churn_1M';

---- Remove the last UNION ALL
--SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL'));

--EXEC sp_executesql @sql;

--the above whole code is js automating our task of checking missing values for each column, we need not to write the seperate code for each column,
--we can js execute this function/ procedure which doe sthe same for each column.
-- we found 4 columns with missing values
-- we are calculating percentage of missing values from each column in the below code


--SELECT
--    COUNT(*) AS TotalRows,
--    SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) AS Missing,
--    ROUND(
--        100.0 * SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) / COUNT(*),
--        2
--    ) AS MissingPercentage
--FROM dbo.customer_churn_1M;

--SELECT
--    COUNT(*) AS TotalRows,
--    SUM(CASE WHEN customer_satisfaction IS NULL THEN 1 ELSE 0 END) AS Missing,
--    ROUND(
--        100.0 * SUM(CASE WHEN customer_satisfaction IS NULL THEN 1 ELSE 0 END) / COUNT(*),
--        2
--    ) AS MissingPercentage
--FROM dbo.customer_churn_1M;

--SELECT
--    COUNT(*) AS TotalRows,
--    SUM(CASE WHEN num_complaints IS NULL THEN 1 ELSE 0 END) AS Missing,
--    ROUND(
--        100.0 * SUM(CASE WHEN num_complaints IS NULL THEN 1 ELSE 0 END) / COUNT(*),
--        2
--    ) AS MissingPercentage
--FROM dbo.customer_churn_1M;

--SELECT
--    COUNT(*) AS TotalRows,
--    SUM(CASE WHEN avg_monthly_gb IS NULL THEN 1 ELSE 0 END) AS Missing,
--    ROUND(
--        100.0 * SUM(CASE WHEN avg_monthly_gb IS NULL THEN 1 ELSE 0 END) / COUNT(*),
--        2
--    ) AS MissingPercentage
--FROM dbo.customer_churn_1M;

-- now we are trynna understand if these missing values are random or no, like if these missing values related to churned customers or no. 

--SELECT
--    churn,
--    COUNT(*) AS MissingCount
--FROM dbo.customer_churn_1M
--WHERE annual_income IS NULL
--GROUP BY churn;


--SELECT
--    churn,
--    COUNT(*) AS MissingCount
--FROM dbo.customer_churn_1M
--WHERE customer_satisfaction IS NULL
--GROUP BY churn;


--SELECT
--    churn,
--    COUNT(*) AS MissingCount
--FROM dbo.customer_churn_1M
--WHERE avg_monthly_gb IS NULL
--GROUP BY churn;


--SELECT
--    churn,
--    COUNT(*) AS MissingCount
--FROM dbo.customer_churn_1M
--WHERE num_complaints IS NULL
--GROUP BY churn;

-- finding the overall churn rate, so, we got overall churn rate 10% and 4 columns churn rate 10% so its normal.
--SELECT 
--    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned,
--    COUNT(*) AS total_rows,
--    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS churn_rate_percent
--FROM dbo.customer_churn_1M;

--Checked 4 columns with missing values: num_complaints, avg_monthly_gb, customer_satisfaction, annual_income
--Overall churn rate in the whole dataset: ~9.92% (about 10 out of every 100 customers churn)
--Churn rate among rows with missing values in each of those 4 columns: also ~10%
--Since both numbers match, the missing values aren't linked to churn behavior — they're just random gaps, not a hidden pattern
--Action: safe to fill in the blanks with normal methods (0, median, or mode) — no need for extra "was this missing" flag columns

--That's it. You checked, and the data gave you a green light to clean it simply.


--looks for duplicate customer id as it sbould be unique.

--SELECT customer_id, COUNT(*) 
--FROM dbo.customer_churn_1M
--GROUP BY customer_id
--HAVING COUNT(*) > 1;


-- looks for grabage values in tenure
--SELECT * FROM dbo.customer_churn_1M WHERE tenure < 0;


-- procedure for looking for garbage values in each numeric column

--DECLARE @sql NVARCHAR(MAX) = '';

--SELECT @sql = @sql +
--'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
--        COUNT(*) AS TotalRows,
--        SUM(CASE WHEN [' + COLUMN_NAME + '] < 0 THEN 1 ELSE 0 END) AS NegativeValues
--FROM dbo.customer_churn_1M
--UNION ALL
--'
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'customer_churn_1M'
--AND DATA_TYPE IN ('int', 'float', 'decimal', 'numeric', 'bigint', 'smallint', 'money', 'bit');

---- Remove the last UNION ALL
--SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL'));

--EXEC sp_executesql @sql;

-- checking if each data type is assigned to correct data
--EXEC sp_help 'customer_churn_1M';


-- found age, dependents and tenure as nvarchar, which should be numeric pretty obvious ryt?
--SELECT DISTINCT age FROM customer_churn_1M;
--SELECT DISTINCT dependents FROM customer_churn_1M;
--SELECT DISTINCT tenure FROM customer_churn_1M;

-- checking if they can be converted
--SELECT age FROM customer_churn_1M WHERE TRY_CAST(age AS INT) IS NULL;
--SELECT dependents FROM customer_churn_1M WHERE TRY_CAST(dependents AS INT) IS NULL;
--SELECT tenure FROM customer_churn_1M WHERE TRY_CAST(tenure AS INT) IS NULL;

-- converted them into int
--ALTER TABLE customer_churn_1M ALTER COLUMN age INT;
--ALTER TABLE customer_churn_1M ALTER COLUMN dependents INT;
--ALTER TABLE customer_churn_1M ALTER COLUMN tenure INT;

--converting the signup_date column which was varchar, converted into datetime
--ALTER TABLE customer_churn_1M ALTER COLUMN signup_date DATETIME2;


---- checked if category datatype had any inconsistent or wrong spellling values.
--SELECT DISTINCT gender FROM customer_churn_1M;
--SELECT DISTINCT education FROM customer_churn_1M;
--SELECT DISTINCT marital_status FROM customer_churn_1M;
--SELECT DISTINCT payment_method FROM customer_churn_1M;
--SELECT DISTINCT contract FROM customer_churn_1M;

-- checking outliers in each column
-- DECLARE @sql NVARCHAR(MAX) = '';

-- SELECT @sql = @sql +
-- 'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
--         MIN([' + COLUMN_NAME + ']) AS MinValue,
--         MAX([' + COLUMN_NAME + ']) AS MaxValue
-- FROM customer_churn_1M
-- UNION ALL
-- '
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'customer_churn_1M'
-- AND DATA_TYPE IN ('int', 'float', 'decimal', 'numeric', 'bigint', 'smallint', 'money', 'tinyint');

-- SET @sql = LEFT(@sql, LEN(@sql) - LEN('UNION ALL'));

-- EXEC sp_executesql @sql;