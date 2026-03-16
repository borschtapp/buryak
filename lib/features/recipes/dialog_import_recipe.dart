import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/route_names.dart';
import '../../shared/validator.dart';
import '../../shared/widgets/text_input_dialog.dart';
import '../../shared/repositories/recipe_repository.dart';

void showImportRecipeDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => TextInputDialog(
      title: 'Import Recipe',
      hintText: 'Enter a recipe URL',
      submitLabel: 'Import',
      validator: Validator.validateUrl,
      onSubmit: (url, ctx) async {
        final recipe = await ref.read(recipeRepositoryProvider).import(url);
        if (ctx.mounted) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Recipe imported.'),
              backgroundColor: Colors.green,
            ),
          );
          GoRouter.of(ctx).pushReplacementNamed(RouteNames.recipe, pathParameters: {'rid': recipe.id});
        }
      },
    ),
  );
}
