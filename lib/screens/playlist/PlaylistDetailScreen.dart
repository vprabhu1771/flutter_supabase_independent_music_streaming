import 'package:flutter/material.dart';
import '../../models/Playlist.dart';
import '../song/MusicPlayerScreen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: playlist.songs.isEmpty
          ? const Center(child: Text('No songs in this playlist.'))
          : ListView.builder(
        itemCount: playlist.songs.length,
        itemBuilder: (context, index) {
          final song = playlist.songs[index];
          return ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(song.name), // Assuming Song model has `title`
            subtitle: Text(song.artist?.name ?? 'Unknown Artist'), // Optional
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
          );
        },
      ),
    );
  }
}
