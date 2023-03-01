import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../shared/providers/user.dart';
import '../../shared/views/async_loader.dart';
import '../recipes/view_recipes_grid.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Future<List<RecordModel>> _recipesFuture = UserService.pb.collection('recipes').getList(
    page: 1,
    perPage: 50,
    sort: '-created',
  ).then((value) => value.items);

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<RecordModel>>(
      future: _recipesFuture,
      builder: (context, results) {
        return RecipesGridView(results, isFavorite: false);
      },
    );
  }
}
