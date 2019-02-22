IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results

GO

CREATE TABLE #Results
	(Value      nvarchar(4000),
	 ColumnName nvarchar(4000),
	 TableName  nvarchar(4000)
	)

DECLARE @sql varchar(max) = ''
DECLARE @columnname AS varchar(255) = ''
DECLARE @tablename AS varchar(255) = 'cdi_sentemail'

SET NOCOUNT ON

SELECT
	@columnname = c.name
	 , @sql =
	   @sql + 'select distinct [' + c.name + '] as Value,''' + @columnname + ''' as ColumnName, ''' + @tablename +
	   ''' as TableName from [' + t.name + ']'
	FROM
		sys.columns c
		INNER JOIN sys.tables t
		           ON c.object_id = t.object_id
	WHERE
		t.name = @tablename

BEGIN
-- 	PRINT @sql
	INSERT INTO #Results EXEC (@sql)
END


SELECT
	'['+COLUMNS.COLUMN_NAME + '],' AS columnName
	FROM
		INFORMATION_SCHEMA.COLUMNS
	WHERE
		COLUMNS.TABLE_NAME = @tablename
		-- How many unique values do you need to have in order to return the column
	  AND COLUMNS.COLUMN_NAME NOT IN (SELECT #Results.ColumnName AS ColumnsWithSingleValue
		                                   FROM #Results
	                                       -- where #Results.ColumnName NOT IN ('statecode', 'statuscode')
		                                   GROUP BY #Results.ColumnName
		                                   HAVING count(Value) < 2)
		-- Additional filters against which columns to return								   
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%owning%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%Sink%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%yomi%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%createdonbehalf%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%createdby%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%modifiedonbehalf%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%modifiedby%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%owner%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%version%')
	  AND COLUMNS.COLUMN_NAME NOT LIKE ('%transaction%')
	  -- A very ugly custom sort
	ORDER BY (case COLUMNS.COLUMN_NAME
	    when 'Id' then 1
	    when 'createdon' then 97
	    when 'modifiedon' then 98
		when 'statecode' then 99
		when 'statuscode' then 100
else 2
end), COLUMNS.COLUMN_NAME
