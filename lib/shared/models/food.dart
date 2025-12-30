import 'unit.dart';

class Food {
  int id;
  String name;
  FoodCategory? category;
  String? icon;
  Unit? defaultUnit;

  Food({
    required this.id,
    required this.name,
    this.category,
    this.icon,
    this.defaultUnit,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      category: json['category'] != null ? FoodCategory.fromJson(json['category']) : null,
      icon: json['icon'],
      defaultUnit: json['default_unit'] != null ? Unit.fromJson(json['default_unit']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category?.toJson(),
        'icon': icon,
        'default_unit': defaultUnit?.toJson(),
      };
}

class FoodCategory {
  int id;
  String name;
  FoodCategory? parent;

  FoodCategory({
    required this.id,
    required this.name,
    this.parent,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      id: json['id'],
      name: json['name'],
      parent: json['parent'] != null ? FoodCategory.fromJson(json['parent']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parent': parent?.toJson(),
      };
}
