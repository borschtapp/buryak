class RecipeInstruction {
  int id;
  int? order;
  String? title;
  String text;
  String? url;
  String? image;
  String? video;

  RecipeInstruction({
    required this.id,
    this.order,
    this.title,
    required this.text,
    this.url,
    this.image,
    this.video,
  });

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) {
    return RecipeInstruction(
      id: json['id'],
      order: json['order'],
      title: json['title'],
      text: json['text'],
      url: json['url'],
      image: json['image'],
      video: json['video'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order': order,
    'title': title,
    'text': text,
    'url': url,
    'image': image,
    'video': video,
  };
}
