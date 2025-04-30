using System;
using System.IO;
using LiteDB;

public class Player
{
    public int Id { get; set; }
    public string Kind { get; set; }
    public string Nickname { get; set; }
    public string FullName { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime RegisteredAt { get; set; }
    public int Wins { get; set; }
    public int Loses { get; set; }
    public int TotalGames { get; set; }
    public int Kills { get; set; }
    public int Deaths { get; set; }
    public double KillsToDeath { get; set; } // Ensure this is a double
    public double Accuracy { get; set; } // Ensure this is a double
    public string SerializedStoredItem { get; set; }
}

class Program
{
    static void Main(string[] args)
    {
        // Path to the LiteDB file
        string liteDbPath = "/Users/eastonspehar/Desktop/Readycombat app/edge systems/EDGE-6.1.app/Contents/AppData/246970/arenas/650/players.data";

        // Path to the output log file
        string outputPath = "output.txt";

        try
        {
            // Create a StreamWriter to log output to a file
            using (var writer = new StreamWriter(outputPath))
            {
                // Open the LiteDB database file
                using (var db = new LiteDatabase(liteDbPath))
                {
                    writer.WriteLine("Successfully opened the LiteDB file!");

                    // Get the 'player' collection
                    var playerCollection = db.GetCollection<Player>("player");

                    // Inspect existing collection data to ensure type consistency
                    writer.WriteLine("\nExisting Players in 'player' collection:");
                    foreach (var document in playerCollection.FindAll())
                    {
                        writer.WriteLine(document.ToString());
                        writer.WriteLine("-----------------------------\n");
                    }

                    // Determine the next _id (start at -28 and decrease)
                    int nextId = -28;
                    if (playerCollection.Count() > 0)
                    {
                        // Get the smallest existing _id and decrease it by 1
                        nextId = playerCollection.FindAll()
                            .Select(doc => doc.Id)
                            .Min() - 1;

                        // Ensure it does not go above -28
                        if (nextId >= -28)
                        {
                            nextId = -28;
                        }
                    }

                    // Add a new player with consistent BSON types
                    var newPlayer = new Player
                    {
                        Id = nextId,
                        Kind = "Guest", // Set Kind as a string
                        Nickname = "test",
                        FullName = "test",
                        FirstName = "test",
                        LastName = "", // Set LastName as empty string
                        CreatedAt = DateTime.UtcNow,
                        RegisteredAt = DateTime.UtcNow,
                        Wins = 0,
                        Loses = 0,
                        TotalGames = 0,
                        Kills = 0,
                        Deaths = 0,
                        KillsToDeath = 0.0, // Ensure KillsToDeath is a double
                        Accuracy = 0.0, // Ensure Accuracy is a double
                        SerializedStoredItem = GenerateSerializedStoredItem(nextId, "test", "test", "")
                    };

                    // Insert the new player into the collection
                    playerCollection.Insert(newPlayer);

                    writer.WriteLine($"\nNew player 'test' added with _id {nextId}!");

                    // Log all players from the 'player' collection
                    writer.WriteLine("\nUpdated Players in the 'player' collection:");

                    foreach (var document in playerCollection.FindAll())
                    {
                        writer.WriteLine("\n-----------------------------");
                        writer.WriteLine(document.ToString());
                        writer.WriteLine("-----------------------------\n");
                    }
                }
            }

            Console.WriteLine("Output successfully written to output.txt");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error: {ex.Message}");
        }
    }

    static string GenerateSerializedStoredItem(int id, string nickname, string firstName, string lastName)
    {
        // Ensure that KillsToDeath and Accuracy are explicitly set as double (0.0)
        return $"{{" +
            $"\"Id\":{id}," +
            $"\"Kind\":\"Guest\"," + // Ensure Kind is set as string
            $"\"Profile\":{{" +
                $"\"FirstName\":\"{firstName}\"," +
                $"\"LastName\":\"{lastName}\"," +
                $"\"CreatedAt\":\"{DateTime.Now:yyyy-MM-ddTHH:mm:ss.fffffffK}\"," +
                $"\"RegisteredAt\":\"{DateTime.Now:yyyy-MM-ddTHH:mm:ss.fffffffK}\"," +
                $"\"Nickname\":\"{nickname}\"," +
                $"\"IsMale\":true," +
                $"\"ZipCode\":\"36800\"," +  // ZipCode set as string
                $"\"AvatarUrl\":null" +
            $"}}," +
            $"\"Statistics\":{{" +
                $"\"Wins\":0," +
                $"\"Loses\":0," +
                $"\"Kills\":0," +
                $"\"Deaths\":0," +
                $"\"Shots\":0," +
                $"\"OutHits\":0," +
                $"\"TotalGames\":0," +
                $"\"MaxConsecutiveKills\":0," +
                $"\"BattleCoinsSpent\":0," +
                $"\"KillsToDeath\":0.0," + // Ensure this is a double
                $"\"Accuracy\":0.0" + // Ensure this is a double
            $"}}" +
        $"}}";
    }
}
