import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/feed.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/repositories/import_repository.dart';
import 'notifier_feed.dart';

part 'notifier_feed_list.g.dart';

@riverpod
class FeedList extends _$FeedList {
  final _restoringUrls = <String>{};

  @override
  Future<List<Feed>> build() async {
    final result = await ref
        .watch(feedRepositoryProvider)
        .findAll(
          preload: [FeedPreload.publisher, FeedPreload.total_recipes],
        );
    return result.data;
  }

  Future<void> removeFeed(Feed feed) async {
    final previousState = state;

    if (state.hasValue) {
      state = AsyncData(state.requireValue.where((f) => f.id != feed.id).toList());
    }

    try {
      await ref.read(feedRepositoryProvider).unsubscribe(feed.id);
      ref.invalidate(feedStreamProvider);
    } catch (e) {
      state = previousState;
      ref.invalidateSelf();
      rethrow;
    }
  }

  Future<void> restoreFeed(Feed feed) async {
    if (_restoringUrls.contains(feed.url)) return;
    _restoringUrls.add(feed.url);
    try {
      await ref.read(importRepositoryProvider).import(feed.url, type: 'feed');
      ref.invalidateSelf();
      ref.invalidate(feedStreamProvider);
    } finally {
      _restoringUrls.remove(feed.url);
    }
  }
}
