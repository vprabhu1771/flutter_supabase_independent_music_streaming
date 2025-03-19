import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/widgets/CustomDrawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Genre.dart';
import '../../models/Song.dart';
import 'MusicPlayerScreen.dart';

class MySongScreen extends StatefulWidget {
  final String title;

  const MySongScreen({super.key, required this.title});

  @override
  State<MySongScreen> createState() => _MySongScreenState();
}

class _MySongScreenState extends State<MySongScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Song>> futureSongs;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id;
    futureSongs = fetchSongs();
  }

  Future<List<Song>> fetchSongs() async {
    if (userId == null) {
      return [];
    }

    final response =
    await supabase.from('songs').select('*, artist:users(*)').eq('user_id', userId!);

    print("Raw Data from Supabase: $response");

    final songs = response.map<Song>((song) => Song.fromJson(song)).toList();

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
              setState(() {
                futureSongs = fetchSongs(); // Refresh data
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
            return const Center(child: Text('No songs available.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureSongs = fetchSongs();
              });
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
