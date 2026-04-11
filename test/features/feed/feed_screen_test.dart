import 'package:buryak/features/feed/screen_feed.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/feed_repository.dart';
import 'package:buryak/shared/repositories/recipe_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_recipe.dart';
import '../../helpers/fake_user.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;
  late MockRecipeRepository mockRecipeRepository;
  late User fakeUser;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    mockRecipeRepository = MockRecipeRepository();
    fakeUser = User.fromJson(fakeUserJson());

    // RecipeTile watches recipeIsSaved → savedRecipes → RecipeRepository.findAll.
    // Return an empty list to prevent real HTTP calls and pending retry timers.
    when(
      () => mockRecipeRepository.findAll(
        preload: any(named: 'preload'),
        filter: any(named: 'filter'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer(
      (_) async => PaginatedList(data: [], meta: const Meta(total: 0, limit: 20, offset: 0)),
    );
  });

  Widget createFeedScreen() {
    final container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(mockFeedRepository),
        recipeRepositoryProvider.overrideWithValue(mockRecipeRepository),
      ],
    );
    // build() must run first (returns null), then state can be set safely.
    container.read(authProvider.notifier).state = fakeUser;
    addTearDown(container.dispose);
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Scaffold(body: FeedScreen()),
      ),
    );
  }

  testWidgets('FeedScreen shows recipes from stream', (tester) async {
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

    await tester.pumpWidget(createFeedScreen());
    await tester.pumpAndSettle();

    expect(find.text('Italian Pasta'), findsOneWidget);
  });

  testWidgets('FeedScreen shows error state', (tester) async {
    when(
      () => mockFeedRepository.stream(
        preload: any(named: 'preload'),
        filter: any(named: 'filter'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenThrow(Exception('Failed to load recipes'));

    await tester.pumpWidget(createFeedScreen());
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load recipes'), findsOneWidget);
  });
}
