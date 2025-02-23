import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Playlist.dart';
import '../widgets/CustomDrawer.dart';

class PlaylistScreen extends StatefulWidget {
  final String title;

  const PlaylistScreen({super.key, required this.title});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  String? userId;

  @override
  void initState() {
    super.initState();

    // print(supabase.auth.currentUser?.id);
    setState(() {
      userId = supabase.auth.currentUser?.id;
    });
  }

  /// Stream to listen to real-time changes in the `playlists` table.
  Stream<List<Playlist>> playlistStream() {


    return supabase
        .from('playlists')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId as Object) // Filter playlists where user_id matches
        // .map((data) => data.map((playlist) => Playlist.fromJson(playlist)).toList());
        .map((data) {
          print('Raw data from Supabase: $data'); // Print raw response
          final playlists = data.map((playlist) => Playlist.fromJson(playlist)).toList();
          print('Parsed playlists: $playlists'); // Print parsed Playlist objects
          return playlists;
        });
  }

  /// Function to create a new playlist
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

              final response = await supabase.from('playlists').insert({
                'name': playlistName,
                'user_id': userId,
              });

              if (response != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${response.error!.message}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playlist created successfully!')),
                );
                Navigator.of(context).pop();
                setState(() {}); // Refresh the playlist list
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// Function to edit the playlist name
  Future<void> _editPlaylistName(Playlist playlist) async {
    final TextEditingController _nameController = TextEditingController(text: playlist.name);

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
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = _nameController.text.trim();
              if (newName.isEmpty || newName == playlist.name) {
                Navigator.of(context).pop(); // No changes or empty name
                return;
              }

              try {
                final response = await supabase
                    .from('playlists')
                    .update({'name': newName})
                    .eq('user_id', userId as Object)
                    .eq('id', playlist.id);

                // print(response.toString());
                if (response == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playlist name updated!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update playlist.')),
                  );
                }

                Navigator.of(context).pop(); // Close the dialog
                setState(() {}); // Refresh list
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
                final playlist = playlists[index];
                return Dismissible(
                  key: Key(playlist.id.toString()), // Unique key for each item
                  direction: DismissDirection.endToStart, // Swipe from right to left
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
                        content: Text('Are you sure you want to delete "${playlist.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    final response = await supabase
                        .from('playlists')
                        .delete()
                        .eq('id', playlist.id);

                    if (response != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${response.error!.message}')),
                      );
                    } else {
                      setState(() {
                        playlists.removeAt(index); // Remove from local list
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted "${playlist.name}"')),
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(playlist.name),
                    onTap: () => _editPlaylistName(playlist),
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
