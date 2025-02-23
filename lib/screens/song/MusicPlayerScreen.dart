import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Playlist.dart';
import '../../models/Song.dart';

class MusicPlayerScreen extends StatefulWidget {

  final Song song;

  const MusicPlayerScreen({super.key, required this.song});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {

  final SupabaseClient supabase = Supabase.instance.client;

  final player = AudioPlayer();
  bool isPlaying =false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  String? userId;

  @override
  void initState() {

    super.initState();
    userId = supabase.auth.currentUser?.id;

    // Listen to player state changes

    player.onPlayerStateChanged.listen((state) {
      setState(() {

        isPlaying =state ==PlayerState.playing;
      });
    });

    // Listen to audio position changes
    player.onPositionChanged.listen((position) {
      setState(() {
        currentPosition =position;
      });
    });


    // Listen to total duration of audio file

    player.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration =duration;
      });
    });
  }


  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  Future<void> playPauseAudio() async {
    if (isPlaying) {
      await player.pause();
    }else {
      await player.play(UrlSource(widget.song.song_path));
    }
  }


  String formatTime(Duration duration) {

    String minutes =duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// Fetch playlists for the current user
  Future<List<Playlist>> fetchUserPlaylists() async {
    final response = await supabase
        .from('playlists')
        .select()
        .eq('user_id', userId as Object)
        .order('created_at', ascending: false);

    return (response as List)
        .map((playlist) => Playlist.fromJson(playlist))
        .toList();
  }

  /// Show dialog to select playlist and add the song
  Future<void> showAddToPlaylistDialog() async {
    final playlists = await fetchUserPlaylists();

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No playlists available. Create one first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                title: Text(playlist.name),
                onTap: () => addSongToPlaylist(playlist.id, playlist.name),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Add song to selected playlist
  Future<void> addSongToPlaylist(int playlistId, String playlistName) async {
    final response = await supabase.from('playlist_song').insert({
      'playlist_id': playlistId,
      'song_id': widget.song.id,
    });

    Navigator.of(context).pop(); // Close dialog

    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error!.message}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to "$playlistName" successfully!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: showAddToPlaylistDialog,
            tooltip: 'Add to Playlist',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.song.image_path,
              height: 200,
              width: 200,
              errorBuilder: (context,error,stackTrace) =>
                  Icon(Icons.music_note,size: 100),
            ),
            SizedBox(height:20),
            Text(
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                widget.song.name
            ),
            SizedBox(height:20),
            Slider(
              min:0,
              max: totalDuration.inSeconds.toDouble(),
              value: currentPosition.inSeconds.toDouble(),
              onChanged: (value) async {
                await player.seek(Duration(seconds: value.toInt()));
              },
            ),
            // Text(widget.song.song_path)

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(currentPosition)),
                  Text(formatTime(totalDuration)),
                ],
              ),
            ),
            SizedBox(height: 20),

            TextButton(
              onPressed: playPauseAudio,
              child: Text(isPlaying ? "Pause" : "Play"),

            ),
          ],
        ),
      ),
    );
  }
}