// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rating _$RatingFromJson(Map<String, dynamic> json) => Rating(
  count: (json['count'] as num?)?.toInt(),
  value: (json['value'] as num?)?.toDouble(),
  reviews: (json['reviews'] as num?)?.toInt(),
);

Map<String, dynamic> _$RatingToJson(Rating instance) => <String, dynamic>{
  'count': instance.count,
  'value': instance.value,
  'reviews': instance.reviews,
};
