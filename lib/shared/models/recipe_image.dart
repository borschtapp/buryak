class RecipeImage {
  String url;
  int? width;
  int? height;
  String? caption;

  RecipeImage({
    this.width,
    this.height,
    required this.url,
    this.caption,
  });

  factory RecipeImage.fromJson(Map<String, dynamic> json) {
    return RecipeImage(
      width: json['width'],
      height: json['height'],
      url: json['url'],
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'width': width,
    'height': height,
    'caption': caption,
  };
}
