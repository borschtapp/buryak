// ignore_for_file: scoped_providers_should_specify_dependencies

import 'package:buryak/features/explore/screen_explore.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/repositories/feed_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_recipe.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
  });

  Widget createExploreScreen() {
    return ProviderScope(
      overrides: [
        feedRepositoryProvider.overrideWithValue(mockFeedRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ExploreScreen()),
      ),
    );
  }

  testWidgets('ExploreScreen shows recipes from stream', (tester) async {
    final recipes = [
      Recipe.fromJson(fakeRecipeJson(name: 'Italian Pasta')),
    ];

    when(
      () => mockFeedRepository.stream(
        preload: any(named: 'preload'),
        filter: any(named: 'filter'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer(
      (_) async => PaginatedList(
        data: recipes,
        meta: Meta(total: recipes.length, limit: 20, offset: 0),
      ),
    );

    await tester.pumpWidget(createExploreScreen());
    await tester.pumpAndSettle();

    expect(find.text('Italian Pasta'), findsOneWidget);
  });

  testWidgets('ExploreScreen shows error state', (tester) async {
    when(
      () => mockFeedRepository.stream(
        preload: any(named: 'preload'),
        filter: any(named: 'filter'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenThrow(Exception('Failed to load recipes'));

    await tester.pumpWidget(createExploreScreen());
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load recipes'), findsOneWidget);
  });
}
