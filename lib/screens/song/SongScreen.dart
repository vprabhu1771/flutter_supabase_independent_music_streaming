import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/widgets/CustomDrawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Song.dart';
import 'MusicPlayerScreen.dart';

class SongScreen extends StatefulWidget {
  final String title;

  const SongScreen({super.key, required this.title});

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
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
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      song.image_path,
                      width: 80,
                      height: 80,
                      fit: BoxFit.scaleDown,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text("${song.name}" ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {

                      print(song.id.toString());
                      print(song.name.toString());
                      print(song.image_path.toString());
                      print(song.song_path.toString());
                      print(song.artist?.name.toString());

                      // Play song logic here
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MusicPlayerScreen(song: song),
                        ),
                      );
                    },
                  ),
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
