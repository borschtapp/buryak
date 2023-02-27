import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

import '../../shared/extensions.dart';
import '../../shared/constants.dart';
import '../../shared/providers/user.dart';
import '../../shared/validator.dart';
import '../../shared/views/async_loader.dart';
import 'view_recipes_grid.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final TextEditingController _textFieldController = TextEditingController();

  final Future<List<RecordModel>> _recipesFuture = UserService.pb.collection('user_recipes').getList(
    page: 1,
    perPage: 20,
    sort: '-created',
    expand: 'recipe',
  ).then((rsl) => rsl.items.map((e) => e.expand['recipe']![0]).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: AsyncLoader<List<RecordModel>>(
        future: _recipesFuture,
        builder: (context, results) {
          return RecipesGridView(results, isFavorite: true);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          displayUrlInputDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> displayUrlInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import new recipe'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter a recipe URL"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Import'),
              onPressed: () async {
                if (Validator.validateUrl(_textFieldController.text) == null) {
                  final response = await http.get(
                    Uri.parse('$pocketBaseUrl/api/krip/scrape?url=${_textFieldController.text}'),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.pop(context);

                    final parsedJson = jsonDecode(response.body);
                    final recipeId = parsedJson['id'];

                    final body = <String, dynamic>{
                      "user": UserService.pb.authStore.model.id,
                      "recipe": recipeId,
                    };
                    final record = await UserService.pb.collection('user_recipes').create(body: body);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Recipe imported.'),
                      backgroundColor: Colors.green,
                    ));
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
              },
            ),
          ],
        );
      },
    );
  }

  AppBar? buildAppBar() {
    if (context.isTablet) {
      return null;
    }

    return AppBar(
      centerTitle: true,
      title: SvgPicture.asset("assets/images/logo.svg", height: kToolbarHeight + 20),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ],
    );
  }
}
