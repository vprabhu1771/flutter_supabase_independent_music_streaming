import 'Artist.dart';

class Song {
  final int id;
  final String name;
  final String image_path;
  final String song_path;
  final Artist? artist;

  Song({
    required this.id,
    required this.name,
    required this.image_path,
    required this.song_path,
    this.artist, // Nullable artist
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      name: json['name'],
      image_path: json['image_path'],
      song_path: json['song_path'],
      artist: json['artist'] != null ? Artist.fromJson(json['artist']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_path': image_path,
      'song_path': song_path,
      'artist': artist?.toJson(), // Include artist if not null
    };
  }
}
