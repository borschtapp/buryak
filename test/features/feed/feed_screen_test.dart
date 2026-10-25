import 'package:buryak/features/feed/screen_feed.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/components/recipes/recipe_tile.dart';
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
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

  testWidgets('FeedScreen fills the heart for the user\'s likes and shows others as avatars', (tester) async {
    // Neither recipe is in the (unloaded) saved list; the heart comes from saved_by.
    final recipes = [
      Recipe.fromJson({
        ...fakeRecipeJson(id: 'r1', name: 'Liked by me'),
        'saved_by': [
          {'id': fakeUser.id, 'name': 'Me'},
        ],
      }),
      Recipe.fromJson({
        ...fakeRecipeJson(id: 'r2', name: 'Liked by partner'),
        'saved_by': [
          {'id': 'user-2', 'name': 'Partner'},
        ],
      }),
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

    Finder inTile(String name, Finder matching) => find.descendant(of: find.widgetWithText(RecipeTile, name), matching: matching);
    expect(inTile('Liked by me', find.byIcon(Icons.favorite)), findsOneWidget);
    expect(inTile('Liked by me', find.text('M')), findsNothing, reason: 'own like is the heart, not an avatar');
    expect(inTile('Liked by partner', find.byIcon(Icons.favorite_outline)), findsOneWidget);
    expect(inTile('Liked by partner', find.text('P')), findsOneWidget);
    verifyNever(
      () => mockRecipeRepository.findAll(
        preload: any(named: 'preload'),
        filter: any(named: 'filter'),
        scope: any(named: 'scope'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    );
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
