USE [DatabaseName]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IndexesMaintenance] @database VARCHAR(255)
AS BEGIN
	DECLARE @database_id int;
	SET @database_id = DB_ID(@database);

	DECLARE @object_id INT;
	DECLARE @index_id INT;
	DECLARE @avg_fragmentation_in_percent FLOAT;
	DECLARE @page_count INT;
	DECLARE @table_name VARCHAR(255);
	DECLARE @index_name VARCHAR(255);
	DECLARE @cmd VARCHAR(MAX);

	DECLARE ReBuildCursor CURSOR LOCAL FOR SELECT object_id, index_id, avg_fragmentation_in_percent,page_count FROM sys.dm_db_index_physical_stats(@database_id, null, null, null, null)

	OPEN ReBuildCursor
	FETCH NEXT FROM ReBuildCursor INTO @object_id, @index_id, @avg_fragmentation_in_percent, @page_count;

	WHILE @@FETCH_STATUS = 0 BEGIN

		--IF Fragmentation is less than 3% THEN is OK
		IF @avg_fragmentation_in_percent > 3 BEGIN
			
			SET @table_name = OBJECT_NAME(@object_id);
			SELECT @index_name = name FROM sys.indexes WHERE object_id = @object_id and index_id = @index_id;

			IF @index_name IS NOT NULL BEGIN
				--IF Fragmentation is  less than 30% THEN Reorganize
				IF @avg_fragmentation_in_percent <= 30 BEGIN
					SET @cmd = 'ALTER INDEX ' + @index_name + ' ON ' + @table_name+ ' REORGANIZE ';
					EXEC (@cmd);
					PRINT  @cmd;
				END
				--IF Fragmentation is more than 30% WITH less than 10 pages THEN Reorganize
				IF @avg_fragmentation_in_percent > 30 AND @page_count <= 10 BEGIN				
					SET @cmd = 'ALTER INDEX ' + @index_name + ' ON ' + @table_name + ' REORGANIZE ';
					EXEC (@cmd)
					PRINT  @cmd;
				END
				--IF Fragmentation is more than 30% WITH less than 500 pages THEN Rebuild WITH FILL FACTOR 80
				IF @avg_fragmentation_in_percent > 30 AND @page_count > 10 AND @page_count <= 500  BEGIN
					SET @cmd = 'ALTER INDEX ' + @index_name + ' ON ' + @table_name+ ' REBUILD WITH (FILLFACTOR=80, STATISTICS_NORECOMPUTE=ON, ALLOW_ROW_LOCKS=OFF,ALLOW_PAGE_LOCKS=OFF)';
					EXEC (@cmd)
					PRINT  @cmd;
				END

				--IF Fragmentation is more than 30% WITH less than 200 pages THEN Rebuild WITH FILL FACTOR  60
				IF @avg_fragmentation_in_percent > 30 AND @page_count > 500  BEGIN
					SET @cmd = 'ALTER INDEX ' + @index_name + ' ON ' + @table_name+ ' REBUILD WITH (FILLFACTOR=60, STATISTICS_NORECOMPUTE=ON, ALLOW_ROW_LOCKS=OFF,ALLOW_PAGE_LOCKS=OFF)';
					EXEC (@cmd)
					PRINT  @cmd;
				END
			END
		END


		FETCH NEXT FROM ReBuildCursor INTO @object_id, @index_id, @avg_fragmentation_in_percent, @page_count;
	END

	CLOSE ReBuildCursor
	DEALLOCATE ReBuildCursor
END