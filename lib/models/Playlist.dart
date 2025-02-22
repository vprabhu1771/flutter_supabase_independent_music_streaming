class Playlist {

  int id;

  String name;

  Playlist({
    required this.id,
    required this.name,
  });

  Playlist.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name =json['name'];

}