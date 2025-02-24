import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/models/Playlist.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Song.dart';
import '../../widgets/CustomDrawer.dart';

class PlaylistDetailScreen extends StatefulWidget {

  final String title;

  const PlaylistDetailScreen({super.key, required this.title});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {

  final SupabaseClient supabase = Supabase.instance.client;

  /// Stream to listen to real-time changes in the `playlists` table.
  Stream<List<Playlist>> playlistStream() {
    return supabase
        .from('playlists')
        .select('*, playlist_song(*, songs(*))') // 1️⃣ Fetch data with select
        .asStream()                               // 2️⃣ Convert to stream
        .map((data) {
      return (data as List<dynamic>).map((row) {
        final songs = (row['playlist_song'] as List<dynamic>?)
            ?.map((ps) => Song.fromJson(ps['songs']))
            .toList() ?? [];

        return Playlist(
          id: row['id'],
          name: row['name'],
          // userId: row['user_id'],
          songs: songs,
        );
      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(parentContext: context),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh the StreamBuilder by rebuilding the widget.
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Playlist>>(
        stream: playlistStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final playlists = snapshot.data ?? [];

          if (playlists.isEmpty) {
            return const Center(
              child: Text('No playlists available.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Rebuilds the StreamBuilder to refresh data.
            },
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final row = playlists[index];
                return ListTile(
                  title: Text(row.name),
                  subtitle: Text('${row.songs.length} songs'),
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => SongFilterByGenreScreen(
                    //       title: genre.name,
                    //       genre: genre,
                    //     ),
                    //   ),
                    // );
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