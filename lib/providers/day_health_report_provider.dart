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
    developer.log('开始加载健康计划');
    state = const AsyncValue.loading();

    try {
      final db = ref.read(databaseProvider);
      final activities = await db.getHealthPlanByDate(date);

      if (activities != null) {
        developer.log('从数据库加载到活动数量: ${activities.length}');
        state = AsyncValue.data(activities);
      } else {
        developer.log('数据库中没有找到记录，获取 HealthReport 数据');
        final healthReport = ref.read(healthReportProvider);

        await healthReport.when(
          data: (activities) async {
            if (activities.isNotEmpty) {
              await db.insertOrUpdateHealthPlan(
                date: date,
                activities: activities,
              );
              state = AsyncValue.data(activities);
            } else {
              state = const AsyncValue.data([]);
            }
          },
          loading: () => state = const AsyncValue.loading(),
          error: (error, stack) => state = AsyncValue.error(error, stack),
        );
      }
    } catch (e, st) {
      developer.log('加载健康计划出错', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}
