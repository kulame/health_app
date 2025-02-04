import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../providers/health_report_provider.dart';
import '../data/database.dart';
import 'dart:convert';

part 'day_health_report_provider.g.dart';

@riverpod
class DayHealthReport extends _$DayHealthReport {
  @override
  AsyncValue<List<ActivityItem>> build() => const AsyncValue.data([]);

  Future<void> loadDayHealthPlan(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(databaseProvider);
      final plan = await db.getHealthPlanByDate(date);

      if (plan != null) {
        // 从数据库加载数据
        final activities = _parseDbPlan(plan);
        state = AsyncValue.data(activities);
      } else {
        // 从 HealthReport 复制数据并保存到数据库
        final healthReport = ref.read(healthReportProvider);
        await healthReport.whenData((activities) async {
          if (activities.isNotEmpty) {
            await _saveToDatabaseAndUpdateState(activities, date);
          } else {
            state = const AsyncValue.data([]); // 如果没有数据，返回空列表
          }
        });
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<ActivityItem> _parseDbPlan(DailyHealthPlan plan) {
    final activities = <ActivityItem>[];

    // 解析晨间活动
    final morningRoutines = jsonDecode(plan.morningRoutine) as List;
    activities.addAll(morningRoutines.map((routine) => ActivityItem(
          title: routine['activity'] as String,
          time: routine['time'] as String,
          kcal: routine['calories'] as String,
          type: ActivityType.activity,
        )));

    // 解析运动
    final exercises = jsonDecode(plan.exercises) as List;
    activities.addAll(exercises.map((exercise) => ActivityItem(
          title: exercise['type'] as String,
          time: exercise['time'] as String,
          kcal: exercise['calories'] as String,
          type: ActivityType.activity,
        )));

    // 解析餐食
    final meals = jsonDecode(plan.meals) as List;
    activities.addAll(meals.map((meal) => ActivityItem(
          title: meal['type'] as String,
          time: meal['time'] as String,
          kcal: meal['calories'] as String,
          type: ActivityType.meal,
          mealItems: (meal['menu'] as List)
              .map((item) => MealItem(
                    name: item as String,
                    kcal: meal['calories'] as String,
                  ))
              .toList(),
        )));

    return activities;
  }

  Future<void> _saveToDatabaseAndUpdateState(
      List<ActivityItem> activities, DateTime date) async {
    final db = ref.read(databaseProvider);

    // 将活动分类
    final morningRoutines = activities
        .where((a) => a.type == ActivityType.activity)
        .take(2)
        .toList();
    final exercises = activities
        .where((a) => a.type == ActivityType.activity)
        .skip(2)
        .toList();
    final meals = activities.where((a) => a.type == ActivityType.meal).toList();

    // 转换为数据库格式
    await db.insertOrUpdateHealthPlan(
      date: date,
      morningRoutine: jsonEncode(morningRoutines
          .map((a) => {
                'time': a.time,
                'activity': a.title,
                'calories': a.kcal,
              })
          .toList()),
      exercises: jsonEncode(exercises
          .map((a) => {
                'time': a.time,
                'type': a.title,
                'calories': a.kcal,
              })
          .toList()),
      meals: jsonEncode(meals
          .map((a) => {
                'time': a.time,
                'type': a.title,
                'calories': a.kcal,
                'menu': a.mealItems?.map((m) => m.name).toList() ?? [],
              })
          .toList()),
    );

    state = AsyncValue.data(activities);
  }
}
