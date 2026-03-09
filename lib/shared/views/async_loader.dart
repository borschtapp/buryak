import 'package:flutter/material.dart';

class AsyncLoader<T> extends StatelessWidget {
  final Future<T> future;
  final String? loadingText;
  final Widget Function(BuildContext context, T snapshot) builder;

  const AsyncLoader({
    super.key,
    required this.future,
    required this.builder,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return builder(context, snapshot.data as T);
        }

        if (snapshot.hasError) {
          debugPrint('AsyncLoader error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Something went wrong. Please try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(loadingText ?? 'Loading...'),
            ],
          ),
        );
      },
    );
  }
}
