import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Genre.dart';
import '../../models/Song.dart';

class SongFilterByGenreScreen extends StatefulWidget {
  final String title;
  final Genre genre;

  const SongFilterByGenreScreen({
    super.key,
    required this.title,
    required this.genre,
  });

  @override
  State<SongFilterByGenreScreen> createState() =>
      _SongFilterByGenreScreenState();
}

class _SongFilterByGenreScreenState extends State<SongFilterByGenreScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Returns a stream of songs filtered by the selected genre.
  Stream<List<Song>> songStreamByGenre(int genreId) {

    // print(genreId);
    return supabase
        .from('songs')
        .stream(primaryKey: ['id'])
        .eq('genre_id', genreId)
        .map((data) => data.map((song) => Song.fromJson(song)).toList());
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
              setState(() {}); // Refresh the StreamBuilder by rebuilding the widget.
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Song>>(
        stream: songStreamByGenre(widget.genre.id),
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
              setState(() {}); // Refresh the data
            },
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return ListTile(
                  title: Text(song.name),
                  onTap: () {
                    // Example action: Pass song ID to a cart or another screen.
                    Map<String, dynamic> cart = {
                      'product_id': song.id,
                    };
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
