// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: json['id'] as String,
  url: json['url'] as String?,
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
      .toList(),
  language: json['language'] as String?,
  publisher: json['publisher'] == null
      ? null
      : Publisher.fromJson(json['publisher'] as Map<String, dynamic>),
  author: json['author'] == null
      ? null
      : Author.fromJson(json['author'] as Map<String, dynamic>),
  text: json['text'] as String?,
  prepTime: (json['prep_time'] as num?)?.toInt(),
  cookTime: (json['cook_time'] as num?)?.toInt(),
  totalTime: (json['total_time'] as num?)?.toInt(),
  difficulty: json['difficulty'] as String?,
  method: json['method'] as String?,
  taxonomies: (json['taxonomies'] as List<dynamic>?)
      ?.map((e) => Taxonomy.fromJson(e as Map<String, dynamic>))
      .toList(),
  yield: (json['yield'] as num?)?.toInt(),
  equipment: (json['equipment'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ingredients: (json['ingredients'] as List<dynamic>?)
      ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => RecipeInstruction.fromJson(e as Map<String, dynamic>))
      .toList(),
  nutrition: json['nutrition'] == null
      ? null
      : Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
  rating: json['rating'] == null
      ? null
      : Rating.fromJson(json['rating'] as Map<String, dynamic>),
  video: json['video'] == null
      ? null
      : Video.fromJson(json['video'] as Map<String, dynamic>),
  published: json['published'] == null
      ? null
      : DateTime.parse(json['published'] as String),
  updated: DateTime.parse(json['updated'] as String),
  created: DateTime.parse(json['created'] as String),
  feedId: json['feed_id'] as String?,
  feed: json['feed'] == null
      ? null
      : Feed.fromJson(json['feed'] as Map<String, dynamic>),
  isBasedOn: json['is_based_on'] as String?,
  isSaved: json['is_saved'] as bool?,
  parentId: json['parent_id'] as String?,
  userId: json['user_id'] as String?,
  householdId: json['household_id'] as String?,
  collections: (json['collections'] as List<dynamic>?)
      ?.map((e) => Collection.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'name': instance.name,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'images': instance.images,
  'language': instance.language,
  'publisher': instance.publisher,
  'author': instance.author,
  'text': instance.text,
  'prep_time': instance.prepTime,
  'cook_time': instance.cookTime,
  'total_time': instance.totalTime,
  'difficulty': instance.difficulty,
  'method': instance.method,
  'taxonomies': instance.taxonomies,
  'yield': instance.yield,
  'equipment': instance.equipment,
  'ingredients': instance.ingredients,
  'instructions': instance.instructions,
  'nutrition': instance.nutrition,
  'rating': instance.rating,
  'video': instance.video,
  'published': instance.published?.toIso8601String(),
  'updated': instance.updated.toIso8601String(),
  'created': instance.created.toIso8601String(),
  'feed_id': instance.feedId,
  'feed': instance.feed,
  'is_based_on': instance.isBasedOn,
  'is_saved': instance.isSaved,
  'parent_id': instance.parentId,
  'user_id': instance.userId,
  'household_id': instance.householdId,
  'collections': instance.collections,
};
