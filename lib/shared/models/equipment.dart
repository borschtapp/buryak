import 'package:json_annotation/json_annotation.dart';

part 'equipment.g.dart';

@JsonSerializable()
class Equipment {
  final String id;
  final String name;
  final String? description;
  final String? slug;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  Equipment({
    required this.id,
    required this.name,
    this.description,
    this.slug,
    this.imageUrl,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => _$EquipmentFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentToJson(this);
}
