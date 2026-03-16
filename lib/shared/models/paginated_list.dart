import 'package:json_annotation/json_annotation.dart';

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

@JsonSerializable()
class Meta {
  final int total;
  final int limit;
  final int offset;

  Meta({
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
