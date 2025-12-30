import 'food.dart';
import 'unit.dart';

class RecipeIngredient {
  int id;
  num amount;
  String? note;
  String text;
  Unit? unit;
  Food? food;

  RecipeIngredient({
    required this.id,
    required this.amount,
    this.note,
    required this.text,
    this.unit,
    this.food,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      amount: json['amount'],
      note: json['note'],
      text: json['text'],
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
      food: json['food'] != null ? Food.fromJson(json['food']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'note': note,
        'text': text,
        'unit': unit?.toJson(),
        'food': food?.toJson(),
      };
}
