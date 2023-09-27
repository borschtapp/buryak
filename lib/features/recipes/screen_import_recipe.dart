import 'dart:convert';

import 'package:buryak/shared/views/article_content.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../shared/constants.dart';
import '../../shared/providers/user.dart';
import '../../shared/validator.dart';

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

  onPressed() async {
    if (Validator.validateUrl(_textFieldController.text) == null) {
      final response = await http.get(
        Uri.parse('$pocketBaseUrl/api/krip/scrape?url=${_textFieldController.text}'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsedJson = jsonDecode(response.body);
        final recipeId = parsedJson['id'];

        final body = <String, dynamic>{
          "user": UserService.pb.authStore.model.id,
          "recipe": recipeId,
        };
        final record = await UserService.pb.collection('user_recipes').create(body: body);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Recipe imported.'),
          backgroundColor: Colors.green,
        ));

        GoRouter.of(context).goNamed('recipe', pathParameters: {'rid': recipeId});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${response.statusCode}'),
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
