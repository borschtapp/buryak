import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe_saved_user.freezed.dart';
part 'recipe_saved_user.g.dart';

@freezed
abstract class RecipeSavedUser with _$RecipeSavedUser {
  const factory RecipeSavedUser({
    required String id,
    String? name,
    String? imageUrl,
  }) = _RecipeSavedUser;

  factory RecipeSavedUser.fromJson(Map<String, dynamic> json) =>
      _$RecipeSavedUserFromJson(json);
}
