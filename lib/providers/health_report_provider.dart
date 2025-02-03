import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../services/gpt_service.dart';
import '../models/activity_item.dart';
import 'activity_provider.dart';
import 'dart:developer' as developer;
import 'dart:convert';

part 'health_report_provider.g.dart';

@riverpod
class HealthReport extends _$HealthReport {
  @override
  AsyncValue<List<ActivityItem>> build() => const AsyncValue.data([]);

  Future<void> analyzeReport(File file) async {
    state = const AsyncValue.loading();
    try {
      final gptService = GptService();
      final pdfText = await gptService.extractTextFromPdf(file);
      print('Extracted PDF text: $pdfText');

      final rawResponse = await gptService.analyzeHealthReport(pdfText);
      final activities = _parseActivities(rawResponse);

      state = AsyncValue.data(activities);
    } catch (e, st) {
      print('Error in analyzeReport: $e\n$st');
      state = AsyncValue.error(e, st);
    }
  }

  List<ActivityItem> _parseActivities(Map<String, dynamic> rawData) {
    final activities = <ActivityItem>[];
    final dailyPlan = rawData['dailyPlan'] as Map<String, dynamic>;

    // 处理晨间活动
    for (var routine in dailyPlan['morningRoutine'] as List) {
      activities.add(ActivityItem(
        title: routine['activity'] as String,
        time: routine['time'] as String,
        kcal: routine['calories'] as String,
        type: ActivityType.activity,
      ));
    }

    // 处理运动
    for (var exercise in dailyPlan['exercises'] as List) {
      activities.add(ActivityItem(
        title: exercise['type'] as String,
        time: exercise['time'] as String,
        kcal: exercise['calories'] as String,
        type: ActivityType.activity,
      ));
    }

    // 处理餐食
    for (var meal in dailyPlan['meals'] as List) {
      activities.add(ActivityItem(
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
      ));
    }

    return activities;
  }
}
