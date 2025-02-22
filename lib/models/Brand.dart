class Brand {

  int id;
  String name;
  String image_path;

  Brand({
    required this.id,
    required this.name,
    required this.image_path,
  });

  Brand.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name =json['name'],
        image_path=json['image_path'];
}