import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity_item.dart';
import '../providers/database_provider.dart';
import '../providers/health_report_provider.dart';
import '../data/database.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

part 'day_health_report_provider.g.dart';

@riverpod
class DayHealthReport extends _$DayHealthReport {
  @override
  AsyncValue<List<ActivityItem>> build() {
    ref.listen(healthReportProvider, (previous, next) {
      developer.log('HealthReport 发生变化: $next');
    });

    return const AsyncValue.data([]);
  }

  Future<void> loadDayHealthPlan(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    developer.log('开始加载健康计划, 日期: $dateStr');
    state = const AsyncValue.loading();

    try {
      developer.log('尝试从数据库读取数据');
      final db = ref.read(databaseProvider);
      final plan = await db.getHealthPlanByDate(date);

      if (plan != null) {
        developer.log('数据库中找到记录: ${plan.toString()}');
        developer.log('开始解析数据库数据');
        final activities = _parseDbPlan(plan);
        developer.log('解析完成，活动数量: ${activities.length}');
        state = AsyncValue.data(activities);
      } else {
        developer.log('数据库中没有找到记录，获取 HealthReport 数据');
        final healthReport = ref.read(healthReportProvider);

        developer.log('HealthReport 当前状态: $healthReport');
        await healthReport.when(
          data: (activities) async {
            developer.log('获取到 HealthReport 数据，长度: ${activities.length}');
            if (activities.isNotEmpty) {
              developer.log('从 HealthReport 获取到有效数据');
              await _saveToDatabaseAndUpdateState(activities, date);
            } else {
              state = const AsyncValue.data([]);
            }
          },
          loading: () {
            developer.log('HealthReport 正在加载中');
            state = const AsyncValue.loading();
          },
          error: (error, stack) {
            developer.log('HealthReport 发生错误', error: error, stackTrace: stack);
            state = AsyncValue.error(error, stack);
          },
        );
      }
    } catch (e, st) {
      developer.log('加载健康计划出错', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  List<ActivityItem> _parseDbPlan(DailyHealthPlan plan) {
    developer.log('开始解析数据库计划');
    final activities = <ActivityItem>[];

    try {
      // 解析晨间活动
      developer.log('解析晨间活动');
      final morningRoutines = jsonDecode(plan.morningRoutine) as List;
      developer.log('晨间活动数据: $morningRoutines');
      activities.addAll(morningRoutines.map((routine) => ActivityItem(
            title: routine['activity'] as String,
            time: routine['time'] as String,
            kcal: routine['calories'] as String,
            type: ActivityType.activity,
          )));

      // 解析运动
      developer.log('解析运动活动');
      final exercises = jsonDecode(plan.exercises) as List;
      developer.log('运动活动数据: $exercises');
      activities.addAll(exercises.map((exercise) => ActivityItem(
            title: exercise['type'] as String,
            time: exercise['time'] as String,
            kcal: exercise['calories'] as String,
            type: ActivityType.activity,
          )));

      // 解析餐食
      developer.log('解析餐食活动');
      final meals = jsonDecode(plan.meals) as List;
      developer.log('餐食活动数据: $meals');
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
    } catch (e, st) {
      developer.log('解析数据库计划出错', error: e, stackTrace: st);
      rethrow;
    }

    developer.log('解析完成，总活动数量: ${activities.length}');
    return activities;
  }

  Future<void> _saveToDatabaseAndUpdateState(
      List<ActivityItem> activities, DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    developer.log('开始保存到数据库，日期: $dateStr');
    final db = ref.read(databaseProvider);

    try {
      // 修改活动分类逻辑
      final allActivities =
          activities.where((a) => a.type == ActivityType.activity).toList();
      final morningRoutines = allActivities.take(2).toList();
      final exercises = allActivities.skip(2).toList();

      final meals =
          activities.where((a) => a.type == ActivityType.meal).toList();

      developer.log('晨间活动数量: ${morningRoutines.length}');
      developer.log('运动活动数量: ${exercises.length}');
      developer.log('餐食数量: ${meals.length}');

      // 转换为数据库格式
      final morningRoutineJson = jsonEncode(morningRoutines
          .map((a) => {
                'time': a.time,
                'activity': a.title,
                'calories': a.kcal,
              })
          .toList());
      developer.log('晨间活动 JSON: $morningRoutineJson');

      final exercisesJson = jsonEncode(exercises
          .map((a) => {
                'time': a.time,
                'type': a.title,
                'calories': a.kcal,
              })
          .toList());
      developer.log('运动活动 JSON: $exercisesJson');

      final mealsJson = jsonEncode(meals
          .map((a) => {
                'time': a.time,
                'type': a.title,
                'calories': a.kcal,
                'menu': a.mealItems?.map((m) => m.name).toList() ?? [],
              })
          .toList());
      developer.log('餐食 JSON: $mealsJson');

      await db.insertOrUpdateHealthPlan(
        date: date,
        morningRoutine: morningRoutineJson,
        exercises: exercisesJson,
        meals: mealsJson,
      );
      developer.log('数据库保存成功');

      state = AsyncValue.data(activities);
      developer.log('状态更新完成');
    } catch (e, st) {
      developer.log('保存到数据库出错', error: e, stackTrace: st);
      rethrow;
    }
  }
}
