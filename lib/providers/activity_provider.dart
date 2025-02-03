import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity_item.dart';

part 'activity_provider.g.dart';

@riverpod
class Activities extends _$Activities {
  @override
  List<ActivityItem> build() => const [
        ActivityItem(
          title: 'Get up',
          time: '7:00 AM',
          kcal: '- 100 Kcal',
          type: ActivityType.activity,
        ),
        ActivityItem(
          title: 'Morning Run',
          time: '7:30 AM',
          kcal: '- 350 Kcal',
          type: ActivityType.activity,
        ),
        ActivityItem(
          title: 'Breakfast',
          time: '8:30 AM',
          kcal: '+ 385 Kcal',
          type: ActivityType.meal,
          mealItems: [
            MealItem(name: 'Oatmeal', kcal: '+ 150 Kcal'),
            MealItem(name: 'Banana', kcal: '+ 105 Kcal'),
            MealItem(name: 'Greek Yogurt', kcal: '+ 130 Kcal'),
          ],
        ),
        ActivityItem(
          title: 'Gym Workout',
          time: '10:00 AM',
          kcal: '- 400 Kcal',
          type: ActivityType.activity,
        ),
        ActivityItem(
          title: 'Lunch',
          time: '12:30 PM',
          kcal: '+ 550 Kcal',
          type: ActivityType.meal,
          mealItems: [
            MealItem(name: 'Grilled Chicken', kcal: '+ 250 Kcal'),
            MealItem(name: 'Brown Rice', kcal: '+ 200 Kcal'),
            MealItem(name: 'Salad', kcal: '+ 100 Kcal'),
          ],
        ),
        // ... 更多数据
      ];

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
