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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ArticleContent(
      child: Column(
        children: [
          TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter a recipe URL'),
            textInputAction: TextInputAction.go,
            onSubmitted: _isLoading ? null : (_) => onSubmitted(),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(onPressed: onSubmitted, child: const Text('Import')),
        ],
      ),
    );
  }

  Future<void> onSubmitted() async {
    final validationError = Validator.validateUrl(_textFieldController.text);
    if (validationError == null) {
      setState(() {
        _isLoading = true;
      });
      try {
        Recipe recipe = await RecipeRepository.import(_textFieldController.text);

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text('Recipe imported.'),
            backgroundColor: Colors.green,
          ),
        );

        GoRouter.of(context).goNamed('recipe', pathParameters: {'rid': recipe.id});
      } catch (e) {
        String msg = e.toString();
        if (e is GeneralApiException) {
          msg = e.message;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
