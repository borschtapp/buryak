import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_info.freezed.dart';

part 'invite_info.g.dart';

@freezed
abstract class InviteInfo with _$InviteInfo {
  const factory InviteInfo({
    @JsonKey(name: 'household_name') required String householdName,
    @JsonKey(name: 'inviter_name') required String inviterName,
  }) = _InviteInfo;

  factory InviteInfo.fromJson(Map<String, dynamic> json) => _$InviteInfoFromJson(json);
}
