import '../models/activity_item.dart';
import 'dart:convert';

class ActivityItemUtils {
  /// 计算总卡路里
  static String calculateTotalKcal(List<ActivityItem> activities) {
    int total = 0;
    for (final activity in activities) {
      // 提取数字部分并转换为整数
      final kcal =
          int.tryParse(activity.kcal.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
      total += kcal;

      // 如果是餐食，加上所有餐食项的卡路里
      if (activity.type == ActivityType.meal && activity.mealItems != null) {
        for (final meal in activity.mealItems!) {
          final mealKcal =
              int.tryParse(meal.kcal.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
          total += mealKcal;
        }
      }
    }
    return "$total Kcal";
  }

  /// 按时间排序活动
  static List<ActivityItem> sortByTime(List<ActivityItem> activities) {
    final sorted = List<ActivityItem>.from(activities);
    sorted.sort((a, b) => a.time.compareTo(b.time));
    return sorted;
  }

  /// 获取特定类型的活动
  static List<ActivityItem> getActivitiesByType(
    List<ActivityItem> activities,
    ActivityType type,
  ) {
    return activities.where((activity) => activity.type == type).toList();
  }

  /// 将活动列表转换为易读的文本格式
  static String formatToString(List<ActivityItem> activities) {
    if (activities.isEmpty) return '暂无活动';

    final sorted = sortByTime(activities);
    return sorted.map((a) => '''
- ${a.time} ${a.title} (${a.kcal})
  ${a.type == ActivityType.meal && a.mealItems != null ? '包含: ${a.mealItems!.map((m) => "${m.name}(${m.kcal})").join(", ")}' : ''}
''').join();
  }

  /// 比较两个活动列表的差异
  static Map<String, dynamic> comparePlans(
    List<ActivityItem> oldPlan,
    List<ActivityItem> newPlan,
  ) {
    final added = <ActivityItem>[];
    final removed = <ActivityItem>[];
    final modified = <Map<String, ActivityItem>>[];

    // 找出新增和修改的活动
    for (final newActivity in newPlan) {
      final oldActivity = oldPlan.firstWhere(
        (old) => old.time == newActivity.time && old.title == newActivity.title,
        orElse: () => ActivityItem(
          title: '',
          time: '',
          kcal: '',
          type: ActivityType.activity,
        ),
      );

      if (oldActivity.title.isEmpty) {
        added.add(newActivity);
      } else if (jsonEncode(oldActivity.toJson()) !=
          jsonEncode(newActivity.toJson())) {
        modified.add({
          'old': oldActivity,
          'new': newActivity,
        });
      }
    }

    // 找出删除的活动
    for (final oldActivity in oldPlan) {
      final exists = newPlan.any(
        (newActivity) =>
            newActivity.time == oldActivity.time &&
            newActivity.title == oldActivity.title,
      );
      if (!exists) {
        removed.add(oldActivity);
      }
    }

    return {
      'added': added,
      'removed': removed,
      'modified': modified,
      'totalKcalDiff':
          int.parse(calculateTotalKcal(newPlan).replaceAll(' Kcal', '')) -
              int.parse(calculateTotalKcal(oldPlan).replaceAll(' Kcal', '')),
    };
  }

  /// 验证活动列表的有效性
  static bool validateActivities(List<ActivityItem> activities) {
    if (activities.isEmpty) return false;

    for (final activity in activities) {
      // 验证时间格式
      if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
          .hasMatch(activity.time)) {
        return false;
      }

      // 验证卡路里格式
      if (!RegExp(r'^[+-]?\d+\s*Kcal$').hasMatch(activity.kcal)) {
        return false;
      }

      // 验证餐食项
      if (activity.type == ActivityType.meal) {
        if (activity.mealItems == null || activity.mealItems!.isEmpty) {
          return false;
        }
        for (final meal in activity.mealItems!) {
          if (!RegExp(r'^[+-]?\d+\s*Kcal$').hasMatch(meal.kcal)) {
            return false;
          }
        }
      }
    }

    return true;
  }
}
