USE [master]

RESTORE DATABASE [fevflex_mahle] 
FROM  DISK = N'D:\20190902_DB_Backup.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5

GO
