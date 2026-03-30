import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment.freezed.dart';

part 'equipment.g.dart';

@freezed
abstract class Equipment with _$Equipment {
  const factory Equipment({
    required String id,
    required String name,
    String? description,
    String? slug,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _Equipment;

  factory Equipment.fromJson(Map<String, dynamic> json) => _$EquipmentFromJson(json);
}
