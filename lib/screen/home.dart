import 'package:flutter/material.dart';

import '../constants.dart';
import '../component/recipes_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: const SafeArea(
        top: false,
        bottom: false,
        child: RecipesList(),
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
      centerTitle: true, // On Android by default its false
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
