# MSSQL-Scripts
scripts for Microsoft SQL Server database

PRC_ADM_delete_column_20190720.sql
    It's a Administrative procedure that drops columns at MS SQL Server
				- if there is an index or constraint on the column 
					that will be dropped in advice
				=> input parameters are TABLE NAME and COLUMN NAME as STRING
