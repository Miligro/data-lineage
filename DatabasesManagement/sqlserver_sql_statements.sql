-- def create_system_operations_table(self):
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.system_operations') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.system_operations (
        id INT IDENTITY PRIMARY KEY,
        operation_type VARCHAR(255),
        obj_name VARCHAR(255),
        query VARCHAR(MAX),
        UNIQUE(operation_type, obj_name, query)
    );
END;

CREATE PROCEDURE handle_create_table_as_procedure
AS
BEGIN
    DECLARE @EventData XML = EVENTDATA();
    DECLARE @SQLCommand NVARCHAR(MAX) = @EventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)');
    DECLARE @ObjectName NVARCHAR(128) = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(128)');
    INSERT INTO system_operations(operation_type, obj_name, query) VALUES('CREATE TABLE', @ObjectName, @SQLCommand);
END

CREATE TRIGGER create_table_as_trigger
ON DATABASE
FOR CREATE_TABLE
AS
BEGIN
    EXEC handle_create_table_as_procedure
END

-- -----------------------------------------------------------------

CREATE EVENT SESSION [MonitorCreateTable] ON SERVER
ADD EVENT sqlserver.object_created
(
    ACTION(sqlserver.sql_text)
    WHERE sqlserver.database_name = N'bank' AND
        sqlserver.sql_text LIKE '%SELECT%INTO%#%' AND
        sqlserver.sql_text NOT LIKE '%INTO%#@%' AND
        sqlserver.sql_text NOT LIKE '%INTO%##%'
)
ADD TARGET package0.event_file(SET filename=N'EventFile.xel', max_file_size=(51200))
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=ON, STARTUP_STATE=OFF);

ALTER EVENT SESSION [MonitorCreateTable] ON SERVER STATE = START;

INSERT INTO system_operations (operation_type, obj_name, query)
SELECT
    DISTINCT 'CREATE TABLE',
    event_data.value( '(event/data[@name="object_name"]/value)[1]', 'nvarchar(255)' ) AS object_name,
    event_data.value( '(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)' ) AS sql_text
FROM
    (SELECT CAST(event_data AS XML) AS event_data
     FROM sys.fn_xe_file_target_read_file('EventFile*.xel', NULL, NULL, NULL)) AS tab;

