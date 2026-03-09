import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/views/async_loader.dart';
import '../recipes/view_recipes_grid.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<Recipe>> _streamFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _streamFuture = FeedRepository.stream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<Recipe>>(
      future: _streamFuture,
      builder: (context, results) {
        return RecipesGridView(results, isFavorite: false);
      },
    );
  }
}
