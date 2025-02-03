// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityItemImpl _$$ActivityItemImplFromJson(Map<String, dynamic> json) =>
    _$ActivityItemImpl(
      title: json['title'] as String,
      time: json['time'] as String,
      kcal: json['kcal'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      mealItems: (json['mealItems'] as List<dynamic>?)
          ?.map((e) => MealItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ActivityItemImplToJson(_$ActivityItemImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'time': instance.time,
      'kcal': instance.kcal,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'mealItems': instance.mealItems,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.activity: 'activity',
  ActivityType.meal: 'meal',
};

_$MealItemImpl _$$MealItemImplFromJson(Map<String, dynamic> json) =>
    _$MealItemImpl(
      name: json['name'] as String,
      kcal: json['kcal'] as String,
    );

Map<String, dynamic> _$$MealItemImplToJson(_$MealItemImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'kcal': instance.kcal,
    };
