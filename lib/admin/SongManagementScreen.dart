import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Song.dart';
import '../screens/song/MusicPlayerScreen.dart';
import '../widgets/CustomDrawer.dart';

class SongManagementScreen extends StatefulWidget {

  final String title;

  const SongManagementScreen({super.key, required this.title});

  @override
  State<SongManagementScreen> createState() => _SongManagementScreenState();
}

class _SongManagementScreenState extends State<SongManagementScreen> {

  final SupabaseClient supabase = Supabase.instance.client;

  /// Fetches the list of songs along with user details.
  Future<List<Song>> fetchSongs() async {
    final response = await supabase.from('songs').select('*, artist:users(*)');

    print("Raw Data from Supabase: $response");

    final songs = response.map((song) => Song.fromJson(song)).toList();

    print("Parsed Songs List: $songs");

    return songs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Triggers UI rebuild
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Song>>(
        future: fetchSongs(), // Calls fetchSongs() only once
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading songs: ${snapshot.error}'),
            );
          }

          final songs = snapshot.data ?? [];

          if (songs.isEmpty) {
            return const Center(child: Text('No songs available.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Triggers UI rebuild
            },
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  title: Text("${song.name}" ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerScreen(song: song),
                      ),
                    );
                    print('Selected song: ${song.name} with ID: ${song.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
