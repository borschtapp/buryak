import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../shared/constants.dart';
import '../../shared/service/user.dart';
import '../../shared/validator.dart';
import '../../shared/views/async_loader.dart';
import '../../shared/views/recipes_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: SafeArea(
        top: false,
        bottom: false,
        child: AsyncLoader<List<RecordModel>>(
          future: _recipesFuture,
          builder: (context, results) {
            return RecipesList(results, isFavorite: true);
          },
        ),
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

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: borschtColor,
      leading: const SizedBox(),
      // leading: IconButton(
      //   icon: SvgPicture.asset("assets/icons/menu.svg"),
      //   onPressed: () {},
      // ),
      centerTitle: true,
      // On Android by default its false
      title: SvgPicture.asset("assets/images/logo.svg", height: 90),
      // title: const Text("Borscht"),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        const SizedBox(width: 5)
      ],
    );
  }
}
