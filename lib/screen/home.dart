import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../service/user.dart';
import '../utils/validator.dart';
import '../widget/recipes_list.dart';
import '../widget/async_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textFieldController = TextEditingController();

  final Future<ResultList<RecordModel>> _recipesFuture = UserService.pb.collection('recipes').getList(
    page: 1,
    perPage: 20,
    sort: '-created',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AsyncLoader<ResultList<RecordModel>>(
          future: _recipesFuture,
          builder: (context, results) {
            return RecipesList(results.items);
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
              onPressed: () {
                if (Validator.validateUrl(_textFieldController.text) == null) {
                  Navigator.pop(context);
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
      // title: Image.asset("assets/images/logo.png"),
      title: const Text("Borscht"),
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
