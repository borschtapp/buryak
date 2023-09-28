class Publisher {
  int id;
  String name;
  String url;
  String? description;
  String? image;

  Publisher({
    required this.id,
    required this.name,
    required this.url,
    this.description,
    this.image,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'description': description,
    'image': image,
  };
}
