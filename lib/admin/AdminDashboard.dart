import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Song.dart';
import '../widgets/CustomDrawer.dart';
import '../screens/song/MusicPlayerScreen.dart';

class AdminDashboard extends StatefulWidget {
  final String title;

  const AdminDashboard({super.key, required this.title});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetch Songs from Supabase
  Future<List<Song>> fetchSongs() async {
    final response = await supabase.from('songs')
        .select('*, artist:users(*)')
        .order('created_at', ascending: false) // Order by latest uploads
        .limit(5); // Get only the latest 5 songs

    print("Raw Data from Supabase: $response");

    final songs = response.map((song) => Song.fromJson(song)).toList();

    print("Parsed Songs List: $songs");

    return songs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
            onPressed: () {
              setState(() {}); // Refresh dashboard
            },
          ),
        ],
      ),
      drawer: CustomDrawer(parentContext: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Dashboard Overview Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Users", "1.2K", FontAwesomeIcons.userGroup, Colors.blue),
                _buildStatCard("Songs", "5.6K", FontAwesomeIcons.music, Colors.orange),
                _buildStatCard("Artists", "280", FontAwesomeIcons.microphone, Colors.green),
                // _buildStatCard("Albums", "120", FontAwesomeIcons.recordVinyl, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),

            // 📌 Recent Uploads Section
            const Text(
              "Recent Uploads",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📌 Fetch & Display Songs
            Expanded(
              child: FutureBuilder<List<Song>>(
                future: fetchSongs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final songs = snapshot.data ?? [];
                  if (songs.isEmpty) {
                    return const Center(child: Text('No songs available.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {}); // Trigger refresh
                    },
                    child: ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) => _buildSongTile(songs[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 Widget for Dashboard Cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 80,
        height: 120,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 28, color: color), // FontAwesome icon
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// 📌 Widget for Recent Uploads List
  Widget _buildSongTile(Song song) {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.music, color: Colors.blue), // FontAwesome icon
      title: Text(song.name, style: const TextStyle(fontWeight: FontWeight.bold)), // Song Name
      subtitle: Text(song.artist?.name ?? "Unknown Artist"), // Artist Name

      // **Fetch and Display Song Duration**
      trailing: FutureBuilder<Duration?>(
        future: song.fetchDuration(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Text("N/A", style: TextStyle(color: Colors.grey));
          }
          final duration = snapshot.data!;
          final minutes = duration.inMinutes;
          final seconds = duration.inSeconds.remainder(60);
          return Text("$minutes:${seconds.toString().padLeft(2, '0')}", style: const TextStyle(color: Colors.grey));
        },
      ),

      onTap: () {
        // Navigate to Music Player Screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MusicPlayerScreen(song: song)),
        );
      },
    );
  }

}
