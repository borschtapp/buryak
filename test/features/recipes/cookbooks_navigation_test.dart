import 'package:buryak/features/recipes/screen_cookbooks.dart';
import 'package:buryak/features/recipes/screen_saved.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/collection.dart';
import 'package:buryak/shared/models/household.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/collection_repository.dart';
import 'package:buryak/shared/repositories/household_repository.dart';
import 'package:buryak/shared/repositories/recipe_repository.dart';
import 'package:buryak/shared/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_user.dart';

class MockHouseholdRepository extends Mock implements HouseholdRepository {}
class MockRecipeRepository extends Mock implements RecipeRepository {}
class MockCollectionRepository extends Mock implements CollectionRepository {}

class MockAuthNotifier extends AuthNotifier {
  final User? initialUser;
  MockAuthNotifier(this.initialUser);
  @override
  User? build() => initialUser;
}

void main() {
  testWidgets('tapping See all navigates to CookbooksScreen', (tester) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/saved';
    addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

    final mockHousehold = MockHouseholdRepository();
    final mockRecipe = MockRecipeRepository();
    final mockCollection = MockCollectionRepository();

    when(() => mockHousehold.findOne(any(), preload: any(named: 'preload'))).thenAnswer(
      (_) async => const Household(id: 'h1', ownerId: 'u1', name: 'Home'),
    );
    when(() => mockHousehold.findMembers(any())).thenAnswer(
      (_) async => PaginatedList(data: <User>[], meta: const Meta(total: 0, limit: 20, offset: 0)),
    );
    when(() => mockRecipe.findAll(
      scope: any(named: 'scope'),
      preload: any(named: 'preload'),
      filter: any(named: 'filter'),
      offset: any(named: 'offset'),
      limit: any(named: 'limit'),
    )).thenAnswer((_) async => PaginatedList(data: <Recipe>[], meta: const Meta(total: 0, limit: 20, offset: 0)));

    when(() => mockCollection.findAll(
      preload: any(named: 'preload'),
      offset: any(named: 'offset'),
      limit: any(named: 'limit'),
    )).thenAnswer((_) async => PaginatedList(
      data: [const Collection(id: 'c1', userId: 'u1', name: 'My Cookbook', totalRecipes: 2)],
      meta: const Meta(total: 1, limit: 20, offset: 0),
    ));

    final user = User.fromJson(fakeUserJson());
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => MockAuthNotifier(user)),
        householdRepositoryProvider.overrideWithValue(mockHousehold),
        recipeRepositoryProvider.overrideWithValue(mockRecipe),
        collectionRepositoryProvider.overrideWithValue(mockCollection),
      ],
    );
    addTearDown(container.dispose);

    final goRouter = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: goRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    Finder fab(String heroTag) => find.byWidgetPredicate((w) => w is FloatingActionButton && w.heroTag == heroTag);

    expect(find.byType(SavedScreen), findsOneWidget);
    expect(fab('saved_import_fab'), findsOneWidget);
    final seeAllFinder = find.text('See all');
    expect(seeAllFinder, findsOneWidget);

    await tester.tap(seeAllFinder);
    await tester.pumpAndSettle();

    expect(find.byType(CookbooksScreen), findsOneWidget);
    expect(fab('cookbooks_create_fab'), findsOneWidget);
    expect(fab('saved_import_fab'), findsNothing);

    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(SavedScreen), findsOneWidget);
    expect(fab('saved_import_fab'), findsOneWidget);
    expect(fab('cookbooks_create_fab'), findsNothing);
  });
}
