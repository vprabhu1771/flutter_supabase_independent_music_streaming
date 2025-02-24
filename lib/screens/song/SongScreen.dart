import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/widgets/CustomDrawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Genre.dart';
import '../../models/Song.dart';
import 'MusicPlayerScreen.dart';

class SongScreen extends StatefulWidget {
  final String title;

  const SongScreen({
    super.key,
    required this.title
  });

  @override
  State<SongScreen> createState() =>
      _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Returns a stream of songs filtered by the selected genre.
  Stream<List<Song>> songStream() {

    // print(genreId);
    return supabase
        .from('songs')
        .stream(primaryKey: ['id'])
        // .eq('genre_id', genreId)
        .map((data) => data.map((song) => Song.fromJson(song)).toList());
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
              setState(() {}); // Refresh the StreamBuilder by rebuilding the widget.
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Song>>(
        stream: songStream(),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MusicPlayerScreen(song: song),
                      ),
                    );
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
