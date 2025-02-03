import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_item.freezed.dart';
part 'activity_item.g.dart';

enum ActivityType { activity, meal }

@freezed
class ActivityItem with _$ActivityItem {
  const factory ActivityItem({
    required String title,
    required String time,
    required String kcal,
    required ActivityType type,
    List<MealItem>? mealItems,
  }) = _ActivityItem;

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);
}

@freezed
class MealItem with _$MealItem {
  const factory MealItem({
    required String name,
    required String kcal,
  }) = _MealItem;

  factory MealItem.fromJson(Map<String, dynamic> json) =>
      _$MealItemFromJson(json);
}
