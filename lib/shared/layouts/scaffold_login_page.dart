import 'package:flutter/material.dart';

import '../sections/app_version.dart';
import '../util/breakpoints.dart';

class ScaffoldWithSimpleLayout extends StatelessWidget {
  final Widget child;

  const ScaffoldWithSimpleLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= AppBreakpoints.tablet) {
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                );
              } else if (constraints.maxWidth <= AppBreakpoints.desktop) {
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
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        'assets/images/login_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: AppVersionSection(),
            ),
          ),
        ],
      ),
    );
  }
}
