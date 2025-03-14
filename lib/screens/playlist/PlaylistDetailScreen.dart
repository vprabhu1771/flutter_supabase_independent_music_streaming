import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Playlist.dart';
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
        .select('*, playlist_songs(*, songs(*))') // Fetch playlists with their songs
        .asStream()
        .map((data) {
      print('Raw data from Supabase: $data'); // Print raw response

      return (data as List<dynamic>).map((row) {
        final songs = (row['playlist_songs'] as List<dynamic>?)
            ?.map((ps) => Song.fromJson(ps['songs'])) // Store the parsed Song object
            .toList() ??
            [];

        return Playlist(
          id: row['id'],
          name: row['name'],
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh the StreamBuilder
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final playlists = snapshot.data ?? [];

          if (playlists.isEmpty) {
            return const Center(child: Text('No playlists available.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                return ExpansionTile(
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.songs.length} songs'),
                  children: playlist.songs.map((song) {
                    return ListTile(
                      leading: Image.network(
                        song.image_path,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
                      ),
                      title: Text(song.name),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () {
                        // TODO: Handle song play action
                      },
                    );
                  }).toList(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
