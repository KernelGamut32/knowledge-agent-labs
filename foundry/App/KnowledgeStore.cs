using System.Text.Json;
using Microsoft.Data.Sqlite;

static class KnowledgeStore
{
    public static string DatabasePath => Path.Combine(AppContext.BaseDirectory, "support.db");

    public static void Initialize(bool reset)
    {
        // Existing knowledge persists until the trainer explicitly requests a reset.
        if (!reset && File.Exists(DatabasePath)) return;
        string seed = File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "seed.sql"));
        using var connection = new SqliteConnection(ConnectionString(SqliteOpenMode.ReadWriteCreate));
        connection.Open();
        using var transaction = connection.BeginTransaction();
        using var command = connection.CreateCommand();
        command.Transaction = transaction;
        // Only the trainer-owned setup file is executed. Chat never supplies SQL.
        command.CommandText = seed;
        command.ExecuteNonQuery();
        command.CommandText = "SELECT COUNT(*) FROM knowledge_articles;";
        if ((long)command.ExecuteScalar()! == 0)
            throw new InvalidOperationException("seed.sql must create at least one knowledge article.");
        transaction.Commit(); // A failed seed rolls back, preserving the previous table.
    }

    public static string ReadSupportInfo()
    {
        // This is the agent's read-only connection. The SELECT is fixed in code.
        using var connection = new SqliteConnection(ConnectionString(SqliteOpenMode.ReadOnly));
        connection.Open();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT article_id, title, content FROM knowledge_articles ORDER BY article_id;";
        using var reader = command.ExecuteReader();
        var articles = new List<object>();
        while (reader.Read())
        {
            if (reader.IsDBNull(0) || reader.IsDBNull(1) || reader.IsDBNull(2))
                throw new InvalidOperationException("Knowledge rows must have an ID, title, and content.");
            articles.Add(new { article_id = reader.GetString(0), title = reader.GetString(1), content = reader.GetString(2) });
        }
        if (articles.Count == 0)
            throw new InvalidOperationException("Knowledge is empty. Run with --reset-db to restore seed.sql.");
        return JsonSerializer.Serialize(new { source = "SQLite support.db", articles },
            new JsonSerializerOptions { WriteIndented = true });
    }

    private static string ConnectionString(SqliteOpenMode mode) => new SqliteConnectionStringBuilder
    {
        DataSource = DatabasePath,
        Mode = mode,
        Pooling = false
    }.ToString();
}
