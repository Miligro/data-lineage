using Microsoft.SqlServer.Server;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using System.Data;
using System.Collections;

public partial class UserDefinedFunctions
{
    [SqlFunction(FillRowMethodName = "FillRow")]
    public static IEnumerable ExtractTableReferences(SqlString createTableCommand)
    {
        SqlMetaData[] metaData = new SqlMetaData[] {
            new SqlMetaData("TableName", SqlDbType.NVarChar, 4000)
        };
        ArrayList records = new ArrayList();

        if (!createTableCommand.IsNull)
        {
            string pattern = @"(?:FROM|JOIN)\s+([\w\[\]]+)";
            Regex regex = new Regex(pattern, RegexOptions.IgnoreCase);

            MatchCollection matches = regex.Matches(createTableCommand.Value);
            foreach (Match match in matches)
            {
                SqlDataRecord record = new SqlDataRecord(metaData);
                record.SetString(0, match.Groups[1].Value);
                records.Add(record);
            }
        }

        return records;
    }

    public static void FillRow(object recordObj, out SqlString tableName)
    {
        SqlDataRecord record = (SqlDataRecord)recordObj;
        tableName = new SqlString(record.GetString(0));
    }
}
