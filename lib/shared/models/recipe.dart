import 'publisher.dart';
import 'recipe_image.dart';
import 'recipe_ingredient.dart';
import 'recipe_instruction.dart';

class Recipe {
  int id;
  String? url;
  String name;
  String? description;
  List<RecipeImage>? images;
  String? language;
  Publisher? publisher;
  Author? author;
  String? text;
  int? prepTime;
  int? cookTime;
  int? totalTime;
  String? difficulty;
  String? method;
  List<String>? diets;
  List<String>? categories;
  List<String>? cuisines;
  List<String>? keywords;
  num? yield;
  List<String>? equipment;
  List<RecipeIngredient>? ingredients;
  List<RecipeInstruction>? instructions;

  // Nutrition? nutrition;
  Rating? rating;
  Video? video;
  DateTime? published;
  DateTime updated;
  DateTime created;

  Recipe({
    required this.id,
    this.url,
    required this.name,
    this.description,
    this.language,
    this.author,
    this.text,
    this.prepTime,
    this.cookTime,
    this.totalTime,
    this.difficulty,
    this.method,
    this.diets,
    this.categories,
    this.cuisines,
    this.keywords,
    this.yield,
    this.equipment,
    this.rating,
    this.video,
    this.published,
    required this.updated,
    required this.created,
    this.publisher,
    this.images,
    this.ingredients,
    this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      url: json['url'],
      name: json['name'] as String,
      description: json['description'],
      language: json['language'],
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      text: json['text'],
      prepTime: json['prep_time'],
      cookTime: json['cook_time'],
      totalTime: json['total_time'],
      difficulty: json['difficulty'],
      method: json['method'],
      diets: json['diets']?.cast<String>(),
      categories: json['categories']?.cast<String>(),
      cuisines: json['cuisines']?.cast<String>(),
      keywords: json['keywords']?.cast<String>(),
      yield: json['yield'],
      equipment: json['equipment']?.cast<String>(),
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
      video: json['video'] != null ? Video.fromJson(json['video']) : null,
      published: json['published'] != null ? DateTime.parse(json['published']) : null,
      updated: DateTime.parse(json['updated']),
      created: DateTime.parse(json['created']),
      publisher: json['publisher'] != null ? Publisher.fromJson(json['publisher']) : null,
      images: json['images'] != null ? (json['images'] as List).map((i) => RecipeImage.fromJson(i)).toList() : null,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List).map((i) => RecipeIngredient.fromJson(i)).toList()
          : null,
      instructions: json['instructions'] != null
          ? (json['instructions'] as List).map((i) => RecipeInstruction.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'name': name,
        'description': description,
        'language': language,
        'author': author?.toJson(),
        'text': text,
        'prep_time': prepTime,
        'cook_time': cookTime,
        'total_time': totalTime,
        'difficulty': difficulty,
        'method': method,
        'diets': diets,
        'categories': categories,
        'cuisines': cuisines,
        'keywords': keywords,
        'yield': yield,
        'equipment': equipment,
        'rating': rating?.toJson(),
        'video': video?.toJson(),
        'published': published?.toIso8601String(),
        'updated': updated.toIso8601String(),
        'created': created.toIso8601String(),
        'publisher': publisher?.toJson(),
        'images': images?.map((x) => x.toJson()).toList(),
        'ingredients': ingredients?.map((x) => x.toJson()).toList(),
        'instructions': instructions?.map((x) => x.toJson()).toList(),
      };
}

class Author {
  String? name;
  String? description;
  String? url;
  String? image;

  Author({
    this.name,
    this.description,
    this.url,
    this.image,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'],
      description: json['description'],
      url: json['url'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'url': url,
        'image': image,
      };
}

class Rating {
  int? count;
  num? value;

  Rating({
    this.count,
    this.value,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      count: json['count'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'value': value,
      };
}

class Video {
  String? name;
  String? description;
  String? embedUrl;
  String? contentUrl;
  String? thumbnailUrl;

  Video({
    this.name,
    this.description,
    this.embedUrl,
    this.contentUrl,
    this.thumbnailUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      name: json['name'],
      description: json['description'],
      embedUrl: json['embed_url'],
      contentUrl: json['content_url'],
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'embed_url': embedUrl,
        'content_url': contentUrl,
        'thumbnail_url': thumbnailUrl,
      };
}
