class Artist {
  final String id;
  final String name;
  final String email;
  final String phone;

  Artist({
    required this.id,
    required this.name,
    required this.email,
    required this.phone
  });

  Artist.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        phone = json['phone'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone
    };
  }
}