import 'package:json_annotation/json_annotation.dart';

part 'invite_info.g.dart';

@JsonSerializable()
class InviteInfo {
  @JsonKey(name: 'household_name')
  final String householdName;
  @JsonKey(name: 'inviter_name')
  final String inviterName;

  InviteInfo({
    required this.householdName,
    required this.inviterName,
  });

  factory InviteInfo.fromJson(Map<String, dynamic> json) => _$InviteInfoFromJson(json);

  Map<String, dynamic> toJson() => _$InviteInfoToJson(this);
}
