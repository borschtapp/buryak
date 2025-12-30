import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/recipe.dart';
import '../../shared/repositories/repository.dart';
import '../../shared/repositories/recipe_repository.dart';
import '../../shared/validator.dart';
import '../../shared/views/article_content.dart';

class ImportRecipeScreen extends StatefulWidget {
  const ImportRecipeScreen({super.key});

  @override
  State<ImportRecipeScreen> createState() => _ImportRecipeScreenState();
}

class _ImportRecipeScreenState extends State<ImportRecipeScreen> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ArticleContent(
      child: Column(
        children: [
          TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter a recipe URL"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> onPressed() async {
    if (Validator.validateUrl(_textFieldController.text) == null) {
      try {
        Recipe recipe = await RecipeRepository.scrape(_textFieldController.text);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Recipe imported.'),
          backgroundColor: Colors.green,
        ));

        GoRouter.of(context).goNamed('recipe', pathParameters: {'rid': recipe.id.toString()});
      } catch (e) {
        String msg = e.toString();
        if (e is GeneralApiException) {
          msg = e.message;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(Validator.validateUrl(_textFieldController.text) ?? ''),
        backgroundColor: Colors.red,
      ));
    }
  }
}
