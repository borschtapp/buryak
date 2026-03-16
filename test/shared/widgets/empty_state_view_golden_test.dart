import 'package:buryak/shared/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyStateView Golden Tests', () {
    testWidgets('EmptyStateView renders with basic title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.search_off,
              title: 'No results found',
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(EmptyStateView),
        matchesGoldenFile('goldens/empty_state_basic.png'),
      );
    });

    testWidgets('EmptyStateView renders with subtitle and action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.receipt_long,
              title: 'Your cookbook is empty',
              subtitle: 'Import your first recipe to get started!',
              action: FilledButton(
                onPressed: () {},
                child: const Text('Import Recipe'),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(EmptyStateView),
        matchesGoldenFile('goldens/empty_state_full.png'),
      );
    });
  });
}
