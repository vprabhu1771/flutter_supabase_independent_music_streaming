import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Brand.dart';
import '../../models/Song.dart';
import 'MusicPlayerScreen.dart';

class SongFilterByBrandScreen extends StatefulWidget {
  final String title;
  final Brand brand;

  const SongFilterByBrandScreen({super.key, required this.title, required this.brand});

  @override
  State<SongFilterByBrandScreen> createState() => _SongFilterByBrandScreenState();
}

class _SongFilterByBrandScreenState extends State<SongFilterByBrandScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Song>> futureSongs;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id;
    futureSongs = fetchSongsByBrand(widget.brand.id);
  }

  Future<List<Song>> fetchSongsByBrand(int brandId) async {
    if (userId == null) {
      return [];
    }

    final response = await supabase
        .from('songs')
        .select('*, artist:users(*)')
        .eq('brand_id', brandId);

    print("Raw Data from Supabase: $response");

    final songs = response.map<Song>((song) => Song.fromJson(song)).toList();

    print("Parsed Songs List: $songs");

    return songs;
  }

  void refreshSongs() {
    setState(() {
      futureSongs = fetchSongsByBrand(widget.brand.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshSongs, // Correct refresh logic
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
            return const Center(child: Text('No songs available for this brand.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              refreshSongs();
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
