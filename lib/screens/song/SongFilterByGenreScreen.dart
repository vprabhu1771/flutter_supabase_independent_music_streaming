import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Genre.dart';
import '../../models/Song.dart';
import 'MusicPlayerScreen.dart';

class SongFilterByGenreScreen extends StatefulWidget {
  final String title;
  final Genre genre;

  const SongFilterByGenreScreen({
    super.key,
    required this.title,
    required this.genre,
  });

  @override
  State<SongFilterByGenreScreen> createState() => _SongFilterByGenreScreenState();
}

class _SongFilterByGenreScreenState extends State<SongFilterByGenreScreen> {

  final SupabaseClient supabase = Supabase.instance.client;

  late Future<List<Song>> futureSongs;

  String? userId;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id;
    futureSongs = fetchSongsByGenre(widget.genre.id);
  }

  Future<List<Song>> fetchSongsByGenre(int genreId) async {
    if (userId == null) {
      return [];
    }

    final response = await supabase
        .from('songs')
        .select('*, artist:users(*)')
        .eq('genre_id', genreId);

    print("Raw Data from Supabase: $response");

    final songs = response.map<Song>((song) => Song.fromJson(song)).toList();

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureSongs = fetchSongsByGenre(widget.genre.id); // Refresh data
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Song>>(
        future: futureSongs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final songs = snapshot.data ?? [];

          if (songs.isEmpty) {
            return const Center(child: Text('No songs available for this genre.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureSongs = fetchSongsByGenre(widget.genre.id);
              });
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
                  title: Text(song.name),
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
