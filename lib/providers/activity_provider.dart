import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity_item.dart';

part 'activity_provider.g.dart';

@riverpod
class Activities extends _$Activities {
  @override
  List<ActivityItem> build() => const [];

  void updateActivities(List<ActivityItem> activities) {
    state = activities;
  }

  void updateFromReport(Map<String, dynamic> dailyPlan) {
    final List<ActivityItem> activities = [];

    // 添加晨间活动
    for (var routine in dailyPlan['dailyPlan']['morningRoutine']) {
      activities.add(ActivityItem(
        title: routine['activity'],
        time: routine['time'],
        kcal: routine['calories'],
        type: ActivityType.activity,
      ));
    }

    // 添加运动
    for (var exercise in dailyPlan['dailyPlan']['exercises']) {
      activities.add(ActivityItem(
        title: exercise['type'],
        time: exercise['time'],
        kcal: exercise['calories'],
        type: ActivityType.activity,
      ));
    }

    // 添加餐食
    for (var meal in dailyPlan['dailyPlan']['meals']) {
      activities.add(ActivityItem(
        title: meal['type'],
        time: meal['time'],
        kcal: meal['calories'],
        type: ActivityType.meal,
        mealItems: (meal['menu'] as List)
            .map((item) => MealItem(name: item, kcal: meal['calories']))
            .toList(),
      ));
    }

    state = activities;
  }
}
