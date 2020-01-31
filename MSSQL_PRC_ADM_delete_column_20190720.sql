SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID ('ADM_delete_column', 'P') IS NOT NULL
   DROP procedure ADM_delete_column;
GO

CREATE procedure ADM_delete_column
	@table_name_in 	nvarchar(300)
,	@column_name_in nvarchar(300)
AS 
BEGIN
	/* 	Author: Matthias Guenther (matthis@online.ms at 2019.07.20)
		License CC BY (creativecommons.org)
		Desc: 	Administrative procedure that drops columns at MS SQL Server
				- if there is an index or constraint on the column 
					that will be dropped in advice
				=> input parameters are TABLE NAME and COLUMN NAME as STRING
	*/
	SET NOCOUNT ON

	--drop index if exist (search first if there is a index on the column)
	declare @idx_name VARCHAR(100)
	SELECT	top 1 @idx_name = i.name
	from	sys.tables t
	join	sys.columns c
	on		t.object_id = c.object_id
	join	sys.index_columns ic
	on		c.object_id = ic.object_id
	and		c.column_id = ic.column_id
	join	sys.indexes i
	on		i.object_id = ic.object_id
	and		i.index_id = ic.index_id
	where	t.name like @table_name_in
	and		c.name like @column_name_in
	if		@idx_name is not null
	begin 
		print concat('DROP INDEX ', @idx_name, ' ON ', @table_name_in)
		exec ('DROP INDEX ' + @idx_name + ' ON ' + @table_name_in)
	end

	--drop fk constraint if exist (search first if there is a constraint on the column)
	declare @fk_name VARCHAR(100)
	SELECT	top 1 @fk_name = CONSTRAINT_NAME 
	from 	INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
	where	TABLE_NAME like @table_name_in
	and		COLUMN_NAME like @column_name_in
	if		@fk_name is not null
	begin 
		print concat('ALTER TABLE ', @table_name_in, ' DROP CONSTRAINT ', @fk_name)
		exec ('ALTER TABLE ' + @table_name_in + ' DROP CONSTRAINT ' + @fk_name)
	end

	--drop column if exist
	declare @column_name VARCHAR(100)
	SELECT	top 1 @column_name = COLUMN_NAME 
	FROM	INFORMATION_SCHEMA.COLUMNS 
	WHERE	COLUMN_NAME like concat('%',@column_name_in,'%')
	if		@column_name is not null
	begin 
		print concat('ALTER TABLE ', @table_name_in, ' DROP COLUMN ', @column_name)
		exec ('ALTER TABLE ' + @table_name_in + ' DROP COLUMN ' + @column_name)
	end

	--delete the column from FEVFLEX administartiv tables (columns, columnconfig, columnvalidation, tablevalidation)
	print concat('delete columnconfig where columnconfig_columns_id in (select columns_id from columns where columns_name = ''', @column_name, ''')')
	exec ('delete columnconfig where columnconfig_columns_id in (select columns_id from columns where columns_name = ''' + @column_name + ''')')
	print concat('delete columnvalidation where columnvalidation_columns_id in (select columns_id from columns where columns_name = ''', @column_name, ''')')
	exec ('delete columnvalidation where columnvalidation_columns_id in (select columns_id from columns where columns_name = ''' + @column_name + ''')')
	print concat('delete tablevalidation where tablevalidation_javascript like ''', @column_name, '''')
	exec ('delete tablevalidation where tablevalidation_javascript like  ''' + @column_name + '''')

	print concat('delete columns where columns_name = ''', @column_name, '''')
	exec ('delete columns where columns_name = ''' + @column_name + '''')
end;
GO

/*
--to run the procedure use this execute and fill the parameters 
execute ADM_delete_column 
	@table_name_in 	= ''
,	@column_name_in = ''
	;
*/
