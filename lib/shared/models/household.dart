import 'package:json_annotation/json_annotation.dart';
import 'collection.dart';
import 'feed.dart';
import 'shopping_list.dart';
import 'user.dart';

part 'household.g.dart';

@JsonSerializable()
class Household {
  final String id;
  @JsonKey(name: 'owner_id')
  final String ownerId;
  final String name;

  // Preload fields
  final List<User>? members;
  final List<Feed>? feeds;
  final List<Collection>? collections;
  @JsonKey(name: 'shopping_lists')
  final List<ShoppingList>? shoppingLists;

  Household({
    required this.id,
    required this.ownerId,
    required this.name,
    this.members,
    this.feeds,
    this.collections,
    this.shoppingLists,
  });

  factory Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);
  Map<String, dynamic> toJson() => _$HouseholdToJson(this);
}
