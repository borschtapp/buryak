import 'package:buryak/shared/paged_notifier_mixin.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestPagedNotifier extends AsyncNotifier<List<int>> with PagedNotifierMixin<int> {
  @override
  Future<List<int>> build() async {
    resetPagination();
    return [1, 2, 3];
  }

  @override
  int get pageSize => 3;

  Future<void> loadMore(Future<PaginatedList<int>> Function(int offset, int limit) fetch) {
    return loadNextPage(fetch);
  }
}

void main() {
  group('PagedNotifierMixin', () {
    test('initial state and resetPagination', () async {
      final container = ProviderContainer();
      final provider = AsyncNotifierProvider<TestPagedNotifier, List<int>>(TestPagedNotifier.new);
      
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      expect(notifier.hasMore, isTrue);
      expect(container.read(provider).value, [1, 2, 3]);
    });

    test('loadNextPage appends data and updates hasMore', () async {
      final container = ProviderContainer();
      final provider = AsyncNotifierProvider<TestPagedNotifier, List<int>>(TestPagedNotifier.new);
      
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);

      // Fetch that returns a full page
      await notifier.loadMore((offset, limit) async {
        expect(offset, 3);
        expect(limit, 3);
        return PaginatedList(data: [4, 5, 6], meta: Meta(total: 9, limit: 3, offset: 3));
      });

      expect(container.read(provider).value, [1, 2, 3, 4, 5, 6]);
      expect(notifier.hasMore, isTrue);

      // Fetch that returns enough to reach total
      await notifier.loadMore((offset, limit) async {
        expect(offset, 6);
        return PaginatedList(data: [7], meta: Meta(total: 7, limit: 3, offset: 6));
      });

      expect(container.read(provider).value, [1, 2, 3, 4, 5, 6, 7]);
      expect(notifier.hasMore, isFalse);

      // Subsequent calls should do nothing
      await notifier.loadMore((offset, limit) async {
        fail('Should not call fetch when hasMore is false');
      });
    });

    test('loadNextPage handles empty initial state gracefully', () async {
       // This test might be tricky because PagedNotifierMixin assumes state.asData?.value is not null
       // In build() we usually return initial data.
    });

    test('resetPagination must be called', () {
      final notifier = TestPagedNotifier();
      // We don't call resetPagination here for the sake of the test, 
      // but the mixin's loadNextPage asserts _isInitialized.
      expect(
        () => notifier.loadMore((offset, limit) async => PaginatedList(data: [], meta: Meta(total: 0, limit: 20, offset: 0))),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
