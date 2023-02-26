import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';

import '../../shared/constants.dart';
import '../../shared/service/user.dart';
import '../../shared/validator.dart';
import '../../shared/views/recipes_list.dart';
import '../../shared/views/async_loader.dart';

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
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AsyncLoader<List<RecordModel>>(
          future: _recipesFuture,
          builder: (context, results) {
            return RecipesList(results, isFavorite: false);
          },
        ),
      ),
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
