import 'package:buryak/features/account/screen_account.dart';
import 'package:buryak/features/feed/screen_feed.dart';
import 'package:buryak/shared/models/household.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/feed_repository.dart';
import 'package:buryak/shared/repositories/household_repository.dart';
import 'package:buryak/shared/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_user.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockHouseholdRepository extends Mock implements HouseholdRepository {}

class MockAuthNotifier extends AuthNotifier {
  final User? initialUser;

  MockAuthNotifier(this.initialUser);

  @override
  User? build() => initialUser;
}

void main() {
  late MockFeedRepository mockFeedRepository;
  late MockHouseholdRepository mockHouseholdRepository;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    mockHouseholdRepository = MockHouseholdRepository();
    when(
      () => mockFeedRepository.stream(
        preload: any(named: 'preload'),
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => PaginatedList(data: [], meta: const Meta(total: 0, limit: 20, offset: 0)));
    when(
      () => mockHouseholdRepository.findOne(
        any(),
        preload: any(named: 'preload'),
      ),
    ).thenAnswer(
      (_) async => const Household(
        id: 'household-1',
        ownerId: 'user-1',
        name: 'Test Household',
      ),
    );
    when(() => mockHouseholdRepository.findMembers(any())).thenAnswer(
      (_) async => PaginatedList(
        data: [User.fromJson(fakeUserJson())],
        meta: const Meta(total: 1, limit: 10, offset: 0),
      ),
    );
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Router Guards', () {
    testWidgets('authGuard redirects to /login when not logged in', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(null)), // Not logged in
            feedRepositoryProvider.overrideWithValue(mockFeedRepository),
            householdRepositoryProvider.overrideWithValue(mockHouseholdRepository),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login to your account'), findsOneWidget);
      expect(find.byType(FeedScreen), findsNothing);
    });

    testWidgets('authGuard allows access to / when logged in', (tester) async {
      final user = User.fromJson(fakeUserJson());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => MockAuthNotifier(user)), // Logged in
            feedRepositoryProvider.overrideWithValue(mockFeedRepository),
            householdRepositoryProvider.overrideWithValue(mockHouseholdRepository),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FeedScreen), findsOneWidget);
      expect(find.text('Login to your account'), findsNothing);
    });

    testWidgets('loginGuard redirects to / when already logged in and navigating to /login', (tester) async {
      final user = User.fromJson(fakeUserJson());
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(user)),
          feedRepositoryProvider.overrideWithValue(mockFeedRepository),
          householdRepositoryProvider.overrideWithValue(mockHouseholdRepository),
        ],
      );
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to login
      router.go('/login');
      await tester.pumpAndSettle();

      // Should still be on home (FeedScreen)
      expect(find.byType(FeedScreen), findsOneWidget);
      expect(find.text('Login to your account'), findsNothing);
    });
  });

  group('Deep-link reload', () {
    // These tests cover the regression where reloading at a non-root URL (e.g.
    // /account, /recipes) always redirected to / because the old app.dart showed
    // a bare MaterialApp(home:) while auth loaded — causing Flutter's Navigator
    // to fail silently on the initial route and reset to /.
    //
    // The fix: main() now awaits auth.init() in a ProviderContainer before
    // calling runApp(), so GoRouter always sees the correct auth state from
    // the very first URL match.

    testWidgets('router navigates to /account when auth is pre-initialized', (tester) async {
      // Simulate the browser URL being /account on page reload.
      tester.binding.platformDispatcher.defaultRouteNameTestValue = '/account';
      addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

      final user = User.fromJson(fakeUserJson());

      // Mirrors what main() now does: auth is in the container BEFORE
      // routerProvider (and therefore GoRouter) is created.
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(user)),
          householdRepositoryProvider.overrideWithValue(mockHouseholdRepository),
        ],
      );
      addTearDown(container.dispose);

      // Reading routerProvider here causes GoRouter to read /account as its
      // initial location from platformDispatcher.defaultRouteName.
      final goRouter = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );
      await tester.pumpAndSettle();

      // AccountScreen renders the logged-in user's email — confirm we landed
      // on the right screen instead of being redirected to /login or /.
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Login to your account'), findsNothing);
      expect(find.byType(FeedScreen), findsNothing);
    });

    testWidgets('authGuard redirects to /login on deep link when NOT logged in', (tester) async {
      // Same reload scenario, but with no active session — must redirect to login.
      tester.binding.platformDispatcher.defaultRouteNameTestValue = '/account';
      addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(null)),
          householdRepositoryProvider.overrideWithValue(mockHouseholdRepository),
        ],
      );
      addTearDown(container.dispose);

      final goRouter = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login to your account'), findsOneWidget);
      expect(find.byType(AccountScreen), findsNothing);
    });

    testWidgets('navigating to /account deep link stays on account when logged in', (tester) async {
      final user = User.fromJson(fakeUserJson());
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => MockAuthNotifier(user)),
          feedRepositoryProvider.overrideWithValue(mockFeedRepository),
          householdRepositoryProvider.overrideWithValue(mockHouseholdRepository),
        ],
      );
      addTearDown(container.dispose);

      final goRouter = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Start at home (FeedScreen), then navigate to /account.
      goRouter.go('/account');
      await tester.pumpAndSettle();

      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.text('Login to your account'), findsNothing);
    });
  });
}
