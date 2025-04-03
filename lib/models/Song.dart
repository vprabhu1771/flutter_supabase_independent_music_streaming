import 'package:just_audio/just_audio.dart';
import 'Artist.dart';

class Song {
  final int id;
  final String name;
  final String image_path;
  final String song_path;
  final Artist? artist;
  Duration? duration; // Add duration field

  Song({
    required this.id,
    required this.name,
    required this.image_path,
    required this.song_path,
    this.artist, // Nullable artist
    this.duration, // Optional duration
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

  /// Fetch song duration using `just_audio`
  Future<Duration?> fetchDuration() async {
    try {
      final player = AudioPlayer();
      final duration = await player.setUrl(song_path);
      await player.dispose(); // Dispose player after fetching duration
      return duration;
    } catch (e) {
      print("Error fetching duration: $e");
      return null;
    }
  }
}
