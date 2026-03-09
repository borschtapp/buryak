import 'package:flutter/material.dart';

class ScaffoldWithSimpleLayout extends StatelessWidget {
  final Widget child;

  const ScaffoldWithSimpleLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                child: SizedBox(
                  // width: 300,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, top: 100, bottom: 60),
                    child: child,
                  ),
                ),
              ),
            );
          } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
            return Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 350,
                  child: child,
                ),
              ),
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Image.asset('assets/images/login_bg.png', fit: BoxFit.cover)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 210),
                      child: child,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
