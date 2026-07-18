import 'package:freezed_annotation/freezed_annotation.dart';

import 'collection.dart';
import 'feed.dart';
import 'shopping_list.dart';
import 'user.dart';
import 'user_token.dart';

part 'household.freezed.dart';
part 'household.g.dart';

@freezed
abstract class Household with _$Household {
  const factory Household({
    required String id,
    required String ownerId,
    required String name,
    String? currency,

    // Preload fields
    List<User>? members,
    List<Feed>? feeds,
    List<Collection>? collections,
    List<ShoppingList>? shoppingLists,
    List<UserToken>? invites,
  }) = _Household;

  factory Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);
}
