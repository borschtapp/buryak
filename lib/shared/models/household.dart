import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'household.g.dart';

@JsonSerializable()
class Household {
  final String id;
  final String name;
  final List<User>? members;

  Household({
    required this.id,
    required this.name,
    this.members,
  });

  factory Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);
  Map<String, dynamic> toJson() => _$HouseholdToJson(this);
}
