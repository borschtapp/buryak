import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'view_recipes_grid.dart';
import '../../shared/providers/user.dart';
import '../../shared/views/async_loader.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {

  final Future<List<RecordModel>> _recipesFuture = UserService.pb.collection('user_recipes').getList(
    page: 1,
    perPage: 20,
    sort: '-created',
    expand: 'recipe',
  ).then((rsl) => rsl.items.map((e) => e.expand['recipe']![0]).toList());

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<RecordModel>>(
      future: _recipesFuture,
      builder: (context, results) {
        return RecipesGridView(results, isFavorite: true);
      },
    );
  }
}
