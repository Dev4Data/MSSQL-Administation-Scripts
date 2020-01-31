SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
if (object_id('describe_table') is not null)
	drop procedure describe_table;
go

-- =============================================
create procedure describe_table
    (	@table_name_in	nvarchar(100)
	)
as
begin 
	print concat('show overview data for the table ', @table_name_in)

	declare @col_name varchar(100)
	declare @data_type varchar(100)
	declare column_cursor cursor for
		select 	c.column_name, data_type
		from 	information_schema.columns c
		left join information_schema.key_column_usage as kcu
		on c.column_name = kcu.column_name
		left join information_schema.table_constraints as tc
		on kcu.constraint_name = tc.constraint_name
		where c.table_name like 'workorder'
		and isnull(tc.CONSTRAINT_TYPE,'N/A') not in ('PRIMARY KEY'/*,'FOREIGN KEY'*/)
		order by c.ordinal_position
	open column_cursor
	fetch next from column_cursor into @col_name, @data_type
	while @@FETCH_STATUS = 0
	begin
		print concat(' for column ', @col_name)
		if @data_type in ('bigint','decimal','float','int','smallint','tinyint')
			exec ('select '''+ @col_name + ''' as col_name '
				+ ', count(' + @col_name + ') as cnt '
				+ ', count(distinct ' + @col_name + ') as cnt_dist '
				+ ', sum(case when ' + @col_name + ' is null then 1 else 0 end) as cnt_null '
				+ ', min(' + @col_name + ') as min_val '
				+ ', max(' + @col_name + ') as max_val '
				+ ', avg(' + @col_name + ') as avg_val '
				+ ', var(' + @col_name + ') as variance '
				+ ', stdev(' + @col_name + ') as stddev '
				+ 'from ' + @table_name_in )
		else
			exec ('select '''+ @col_name + ''' as col_name '
				+ ', count(' + @col_name + ') as cnt '
				+ ', count(distinct ' + @col_name + ') as cnt_dist '
				+ ', sum(case when ' + @col_name + ' is null then 1 else 0 end) as cnt_null '
				+ ', min(' + @col_name + ') as min_val '
				+ ', max(' + @col_name + ') as max_val '
				+ 'from ' + @table_name_in )

		exec ('select '''+ @col_name + ''' as col_name '
			+ ', '+ @col_name + ' as value '
			+ ', count(*) as cnt '
			+ 'from ' + @table_name_in + ' '
			+ 'group by ' + @col_name + ' '
			+ 'having count(*) > 1 '
			+ 'order by count(*) desc' )
		fetch next from column_cursor into @col_name, @data_type
	end
end
print '--------------------'
CLOSE column_cursor
DEALLOCATE column_cursor
GO  
