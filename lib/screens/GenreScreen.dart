import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Genre.dart';
import '../screens/song/SongFilterByGenreScreen.dart';

class GenreScreen extends StatefulWidget {
  final String title;

  const GenreScreen({super.key, required this.title});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Stream to listen to real-time changes in the `genres` table.
  Stream<List<Genre>> genreStream() {
    return supabase
        .from('genres')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((genre) => Genre.fromJson(genre)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: StreamBuilder<List<Genre>>(
        stream: genreStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final genres = snapshot.data ?? [];

          if (genres.isEmpty) {
            return const Center(
              child: Text('No genres available.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Rebuilds the StreamBuilder to refresh data.
            },
            child: ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return ListTile(
                  title: Text(genre.name),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SongFilterByGenreScreen(
                          title: genre.name,
                          genre: genre,
                        ),
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
