import 'package:buryak/features/feed/notifier_feed_list.dart';
import 'package:buryak/shared/models/import_result.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/repositories/feed_repository.dart';
import 'package:buryak/shared/repositories/import_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockImportRepository extends Mock implements ImportRepository {}

void main() {
  late MockFeedRepository feeds;
  late MockImportRepository imports;
  late ProviderContainer container;

  setUp(() {
    feeds = MockFeedRepository();
    imports = MockImportRepository();
    container = ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(feeds),
        importRepositoryProvider.overrideWithValue(imports),
      ],
    );
    addTearDown(container.dispose);
    when(() => imports.import('https://example.com', type: 'auto')).thenAnswer((_) async => const ImportResult(created: true));
    when(
      () => feeds.findAll(preload: any(named: 'preload')),
    ).thenAnswer((_) async => PaginatedList(data: const [], meta: const Meta(total: 0, limit: 20, offset: 0)));
  });

  Future<ImportResult> import() => importMutation.run(
    container,
    (tsx) => tsx.get(importerProvider).importUrl('https://example.com', feedOnly: false),
  );

  test('importing from a screen without the feed list does not load it', () async {
    expect((await import()).created, isTrue);

    verifyZeroInteractions(feeds);
  });

  test('importing while the feed list is shown reloads it', () async {
    container.listen(feedListProvider, (_, _) {});
    await container.read(feedListProvider.future);

    await import();
    await container.read(feedListProvider.future);

    verify(() => feeds.findAll(preload: any(named: 'preload'))).called(2);
  });
}
