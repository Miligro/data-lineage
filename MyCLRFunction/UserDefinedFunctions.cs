using System;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    [SqlFunction]
    public static SqlString ExtractTableReferences(SqlString createTableCommand)
    {
        if (createTableCommand.IsNull)
            return SqlString.Null;

        // Pattern to extract table names from FROM and JOIN clauses
        string pattern = @"(?:FROM|JOIN)\s+([\w\[\]]+)(?:\s+AS\s+[\w\[\]]+)?";
        Regex regex = new Regex(pattern, RegexOptions.IgnoreCase);

        MatchCollection matches = regex.Matches(createTableCommand.Value);
        if (matches.Count == 0)
            return SqlString.Null;

        var result = "";
        foreach (Match match in matches)
        {
            // Each match includes the table name which is the first group in the regex pattern
            result += match.Groups[1].Value + ";";
        }

        // Remove the last semicolon
        if (result.Length > 0)
            result = result.Remove(result.Length - 1);

        return new SqlString(result);
    }
}
