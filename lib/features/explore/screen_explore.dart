import 'package:buryak/shared/providers/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';

import '../../shared/extensions.dart';
import '../../shared/models/recipe.dart';
import '../../shared/providers/user.dart';
import '../../shared/validator.dart';
import '../recipes/view_recipe_tile.dart';
import '../recipes/view_recipes_grid.dart';
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
      primary: false,
      appBar: buildAppBar(),
      body: AsyncLoader<List<RecordModel>>(
        future: _recipesFuture,
        builder: (context, results) {
          return RecipesGridView(results, isFavorite: false);
        },
      ),
    );
  }

  AppBar? buildAppBar() {
    if (context.isTablet) {
      return null;
    }

    return AppBar(
      leading: const SizedBox(),
      // leading: IconButton(
      //   icon: SvgPicture.asset("assets/icons/menu.svg"),
      //   onPressed: () {},
      // ),
      centerTitle: true,
      // On Android by default its false
      title: ThemeProvider.logo(context),
      // title: const Text("Borscht"),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ],
    );
  }
}
