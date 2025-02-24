import 'Song.dart';

class Playlist {

  int id;
  String name;
  // final int userId;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    // required this.userId,
    required this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      // userId: json['user_id'],
      songs: (json['songs'] as List<dynamic>?)
          ?.map((songJson) => Song.fromJson(songJson))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    // 'user_id': userId,
    'songs': songs.map((song) => song.toJson()).toList(),
  };


}