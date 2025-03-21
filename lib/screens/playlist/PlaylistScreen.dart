import 'package:flutter/material.dart';
import 'package:flutter_supabase_independent_music_streaming/screens/playlist/PlaylistDetailScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Playlist.dart';
import '../../models/Song.dart';
import '../../widgets/CustomDrawer.dart';

class PlaylistScreen extends StatefulWidget {
  final String title;

  const PlaylistScreen({super.key, required this.title});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  String? userId;

  Future<List<Playlist>>? _playlistsFuture;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id;
    _loadPlaylists();
  }

  void _loadPlaylists() {
    setState(() {
      _playlistsFuture = _fetchPlaylists();
    });
  }

  /// Fetch playlists from Supabase
  Future<List<Playlist>> _fetchPlaylists() async {
    if (userId == null) return [];

    final response = await supabase
        .from('playlists')
        .select('*, playlist_songs(*, songs(*, artist:users(*)))') // Fetch playlists with their songs
        .eq('user_id', userId as Object);

    print(response.toString());

    if (response is List) {
      return response.map((data) => Playlist.fromJson(data)).toList();
    } else {
      return [];
    }
  }

  /// Create a new playlist
  Future<void> _createPlaylist() async {
    final TextEditingController _nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final playlistName = _nameController.text.trim();
              if (playlistName.isEmpty || userId == null) return;

              await supabase.from('playlists').insert({
                'name': playlistName,
                'user_id': userId,
              });

              Navigator.of(context).pop();
              setState(() {
                _playlistsFuture = _fetchPlaylists(); // Refresh playlists
              });
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// Edit playlist name
  Future<void> _editPlaylistName(Playlist playlist) async {
    final TextEditingController _nameController =
    TextEditingController(text: playlist.name);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Playlist Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = _nameController.text.trim();
              if (newName.isEmpty || newName == playlist.name) return;

              await supabase
                  .from('playlists')
                  .update({'name': newName})
                  .eq('id', playlist.id);

              Navigator.of(context).pop();
              setState(() {
                _playlistsFuture = _fetchPlaylists(); // Refresh playlists
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Delete playlist
  Future<void> _deletePlaylist(int playlistId) async {
    await supabase.from('playlists').delete().eq('id', playlistId);
    setState(() {
      _playlistsFuture = _fetchPlaylists(); // Refresh playlists
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
              setState(() {
                _playlistsFuture = _fetchPlaylists();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Playlist>>(
        future: _playlistsFuture,
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
              setState(() {
                _playlistsFuture = _fetchPlaylists();
              });
            },
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                return Dismissible(
                  key: Key(playlist.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete "${playlist.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await _deletePlaylist(playlist.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted "${playlist.name}"')),
                    );
                  },
                  child: ListTile(
                    title: Text(playlist.name),
                    onTap: () {

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlaylistDetailScreen(
                            playlist: playlist,
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _editPlaylistName(playlist),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        child: const Icon(Icons.add),
        tooltip: 'Create Playlist',
      ),
    );
  }
}
