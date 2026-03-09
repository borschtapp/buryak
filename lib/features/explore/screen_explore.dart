import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/providers/feed_notifier.dart';
import '../../shared/views/async_loader.dart';
import '../recipes/view_recipes_grid.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();

  static void showAddFeedDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Add New Feed'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Feed URL (RSS/Atom)',
            helperText: 'Enter the URL of the recipe feed',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isEmpty) return;

              try {
                await FeedRepository.subscribe(url);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feed added! It might take a few minutes for recipes to be processed.'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<Recipe>> _streamFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
    FeedRefreshNotifier().addListener(_refresh);
  }

  @override
  void dispose() {
    FeedRefreshNotifier().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _streamFuture = FeedRepository.stream(preload: 'images,author,publisher,collections,saved');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<Recipe>>(
      future: _streamFuture,
      builder: (context, results) {
        if (results.isEmpty) {
          return const Center(
            child: Text('The feed is still empty.'),
          );
        }
        return RecipesGridView(results, isFavorite: false);
      },
    );
  }
}
