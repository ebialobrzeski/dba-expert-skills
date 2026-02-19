---
name: entities-report-script-builder
description: Creates a dynamic script that loops through all databases and returns a resultset for the query provided based on the template below. User must provide a query to place in this wrapper.
---

# Skill: Multi-Database Report Script Builder

This utility generates a SQL Server script that executes a user-provided query across multiple databases and aggregates results.

## When to Use
- User needs to collect metadata, statistics, or configuration across multiple databases
- User wants a single result set combining data from many databases
- Inventory or audit scenarios requiring database-level aggregation

## Template Usage

**Required Inputs:**
1. **Query**: The T-SQL query to execute in each database
2. **Column Definitions**: Table structure matching the query output (must include ServerName, DatabaseName)
3. **Database Filter**: Comma-separated list of database names or 'ALL'

**Template:**

```sql
-- Declare parameter for database filtering

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF OBJECT_ID('tempdb..##TempReport') IS NOT NULL
DROP TABLE ##TempReport

CREATE TABLE ##TempReport(
	<Table columns matching query output>
)

DECLARE @DBName SYSNAME
DECLARE @SQL NVARCHAR(MAX)

DECLARE Cur_DBs CURSOR FAST_FORWARD FOR
SELECT name
FROM sys.databases d
WHERE database_id > 4

OPEN Cur_DBs

FETCH NEXT FROM Cur_DBs INTO @DBName

WHILE @@FETCH_STATUS = 0
BEGIN
		BEGIN TRY

			SET @SQL = 'USE '+QUOTENAME(@DBName) + ';
			
            <Insert into temp table and query goes here>'

			EXEC(@SQL)

			END TRY

			BEGIN CATCH
				PRINT('Error processing database: ' + @DBName)
			END CATCH
	
	FETCH NEXT FROM Cur_DBs INTO @DBName
END

CLOSE Cur_DBs  
DEALLOCATE Cur_DBs 

SELECT *
FROM ##TempReport
ORDER BY ServerName, DatabaseName

IF OBJECT_ID('tempdb..##TempReport') IS NOT NULL
DROP TABLE ##TempReport
```

## Example Implementation

**User Query:**
```sql
SELECT 
    @@SERVERNAME AS ServerName,
    DB_NAME() AS DatabaseName,
    t.name AS TableName,
    p.rows AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
```

**Complete Script:**
```sql

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF OBJECT_ID('tempdb..##TempReport') IS NOT NULL
DROP TABLE ##TempReport

CREATE TABLE ##TempReport(
	ServerName NVARCHAR(128),
	DatabaseName NVARCHAR(128),
	TableName NVARCHAR(128),
	RowCount BIGINT
)

DECLARE @DBName SYSNAME
DECLARE @SQL NVARCHAR(MAX)

DECLARE Cur_DBs CURSOR FAST_FORWARD FOR
SELECT name
FROM sys.databases d
WHERE database_id > 4

OPEN Cur_DBs
FETCH NEXT FROM Cur_DBs INTO @DBName

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @SQL = 'USE '+QUOTENAME(@DBName) + ';
        INSERT INTO ##TempReport (ServerName, DatabaseName, TableName, RowCount)
        SELECT 
            @@SERVERNAME AS ServerName,
            DB_NAME() AS DatabaseName,
            t.name AS TableName,
            p.rows AS RowCount
        FROM sys.tables t
        INNER JOIN sys.partitions p ON t.object_id = p.object_id
        WHERE p.index_id IN (0,1)'
        
        EXEC(@SQL)
    END TRY
    BEGIN CATCH
        PRINT('Error processing database: ' + @DBName)
    END CATCH
    
    FETCH NEXT FROM Cur_DBs INTO @DBName
END

CLOSE Cur_DBs  
DEALLOCATE Cur_DBs 

SELECT *
FROM ##TempReport
ORDER BY ServerName, DatabaseName

IF OBJECT_ID('tempdb..##TempReport') IS NOT NULL
DROP TABLE ##TempReport
```

## Notes
- Uses `READ UNCOMMITTED` to avoid blocking production workloads
- Skips system databases (`database_id > 4`)
- Error handling continues processing remaining databases on failure
- Temp table must be dropped manually if script is interrupted
- Always include @@SERVERNAME AS ServerName and DB_NAME() AS DatabaseName in the query output