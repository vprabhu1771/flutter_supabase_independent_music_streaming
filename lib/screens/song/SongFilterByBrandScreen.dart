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

  /// Stream to fetch songs filtered by brand ID
  Stream<List<Song>> songStreamByBrand() {
    return supabase
        .from('songs')
        .stream(primaryKey: ['id'])
        .eq('brand_id', widget.brand.id) // Filter by brand ID
        .order('name', ascending: true)
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
              setState(() {}); // Refresh the StreamBuilder
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Song>>(
        stream: songStreamByBrand(),
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
              setState(() {}); // Trigger a refresh
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
