# T-SQL-Script-for-Indexes-maintenance
The following script creates a stored procedure in the database that you want to maintain. The logic of this script is to check index fragmentation and the number of pages. For example, if an index has fragmentation more than 30% and the number of pages is less than 10 then the index reorganized. 

Instructions on how to use Stored Procedure
Step 1:  Create the stored procedure in your database.

Step 2: On Object Explorer - Management - Maintenance Plans, create a new maintenance plan.

Step 3: From the left pane Toolbox, drag and drop [Execute T-SQL Statement Task] element to the plan.

Step 3.1: Open [Execute T-SQL Statement Task] element by double clicking or right click and select Edit...

Step 3.2: Type the following T-SQL Statement and click OK.

==============================================================================================

USE [DatabaseName] 
EXEC IndexesMaintenance [DatabaseName] 
GO

