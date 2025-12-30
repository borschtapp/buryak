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
          return Text(snapshot.error.toString(), style: const TextStyle(color: Colors.cyan, fontSize: 36));
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
