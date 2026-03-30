import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_list.freezed.dart';

part 'paginated_list.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedList<T> {
  final List<T> data;
  final Meta meta;

  PaginatedList({
    required this.data,
    required this.meta,
  });

  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedListFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => _$PaginatedListToJson(this, toJsonT);
}

@freezed
abstract class Meta with _$Meta {
  const factory Meta({
    required int total,
    required int limit,
    required int offset,
  }) = _Meta;

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}
