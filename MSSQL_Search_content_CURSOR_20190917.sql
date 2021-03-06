/* 	Author: Matthias Guenther (matthis@online.ms at 2019.09.17)
	License CC BY (creativecommons.org)
	Desc: 	parse trough all string like columns to find a specific content
*/
declare @search_string nvarchar(50)
set @search_string = 'fill_the_search_string_here';

DECLARE @query nVARCHAR(MAX)
DECLARE @tab AS TABLE (cnt int, tab_name varchar(255), colu_name varchar(255)) 
DECLARE db_cursor CURSOR FOR 
	select	CONCAT(	'select count(*) as cnt, '''
					,t.name,''' as tab_name, '''
					,c.name,''' as colu_name  from "',t.name,
					'" where "',c.name,'" like ''%',@search_string,'%'''
					) as del_sql
	from	sys.columns c 
	join	sys.tables t
	on		c.object_id = t.object_id
	join	sys.types dt
	on		c.user_type_id = dt.user_type_id
	where	dt.name in ('char','text','varchar','nchar','ntext','nvarchar','sysname')
	order by t.name
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @query
WHILE @@FETCH_STATUS = 0
BEGIN
	-- exec (@query) 
	INSERT into @tab EXEC sp_executesql @query
	-- print @query
FETCH NEXT FROM db_cursor INTO @query
END
SELECT t.*, concat('select * from ',tab_name,' where [',colu_name, '] like ''%',@search_string,'%''') as SEL FROM @tab t where cnt > 0
print '--------------------'
CLOSE db_cursor
DEALLOCATE db_cursor
GO
