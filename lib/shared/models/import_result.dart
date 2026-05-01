import 'package:freezed_annotation/freezed_annotation.dart';

import 'feed.dart';
import 'recipe.dart';

part 'import_result.freezed.dart';
part 'import_result.g.dart';

@freezed
abstract class ImportResult with _$ImportResult {
  const factory ImportResult({
    required bool created,
    Feed? feed,
    Recipe? recipe,
  }) = _ImportResult;

  factory ImportResult.fromJson(Map<String, dynamic> json) => _$ImportResultFromJson(json);
}
