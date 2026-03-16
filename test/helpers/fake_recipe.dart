import 'package:buryak/shared/models/recipe.dart';

Map<String, dynamic> fakeRecipeJson({
  String id = '1',
  String name = 'Test Recipe',
  int totalTime = 30,
}) {
  return {
    'id': id,
    'name': name,
    'total_time': totalTime,
    'yield': 4,
    'rating': {'value': 4.5, 'count': 10},
    'images': [{'url': 'https://example.com/image.jpg'}],
    'instructions': [
      {'id': 'i1', 'text': 'Step 1', 'order': 1},
      {'id': 'i2', 'text': 'Step 2', 'order': 2},
    ],
    'created': '2023-01-01T00:00:00Z',
    'updated': '2023-01-01T00:00:00Z',
  };
}

Recipe fakeRecipe({
  String id = '1',
  String name = 'Test Recipe',
  int totalTime = 30,
}) {
  return Recipe.fromJson(fakeRecipeJson(id: id, name: name, totalTime: totalTime));
}
