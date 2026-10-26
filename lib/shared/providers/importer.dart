import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/import_result.dart';
import '../repositories/import_repository.dart';

part 'importer.g.dart';

// Run with `tsx.get(importerProvider)`.
final importMutation = Mutation<ImportResult>(label: 'import');

@Riverpod(keepAlive: true)
class ImportTrigger extends _$ImportTrigger {
  @override
  int build() => 0;

  void trigger() => state++;
}

@Riverpod(keepAlive: true)
Importer importer(Ref ref) => Importer(ref);

/// Imports recipes and feeds. Kept off list notifiers so an import started from
/// another screen doesn't load the lists only to throw them away.
class Importer {
  Importer(this._ref);

  final Ref _ref;

  /// Imports a recipe or feed from [url]; with [feedOnly], only a feed.
  Future<ImportResult> importUrl(String url, {required bool feedOnly}) async {
    final result = await _ref.read(importRepositoryProvider).import(url, type: feedOnly ? 'feed' : 'auto');
    _ref.read(importTriggerProvider.notifier).trigger();
    return result;
  }
}
