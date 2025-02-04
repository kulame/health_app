import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../services/gpt_service.dart';
import '../models/activity_item.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import '../providers/gpt_service_provider.dart';

part 'health_report_provider.g.dart';

@riverpod
class HealthReport extends _$HealthReport {
  @override
  AsyncValue<List<ActivityItem>> build() => const AsyncValue.data([]);

  Future<void> analyzeReport(File file) async {
    state = const AsyncValue.loading();
    try {
      final gptService = ref.read(gptServiceProvider);
      final pdfText = await gptService.extractTextFromPdf(file);
      final rawResponse = await gptService.analyzeHealthReport(pdfText);
      final activities = _parseActivities(rawResponse);
      developer.log('解析完成，活动数量: ${activities.length}');
      state = AsyncValue.data(activities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<ActivityItem> _parseActivities(Map<String, dynamic> rawData) {
    final activities = <ActivityItem>[];
    final dailyPlan = rawData['dailyPlan'] as Map<String, dynamic>;

    activities
      ..addAll(_parseMorningRoutines(dailyPlan['morningRoutine'] as List))
      ..addAll(_parseExercises(dailyPlan['exercises'] as List))
      ..addAll(_parseMeals(dailyPlan['meals'] as List));

    return activities;
  }

  List<ActivityItem> _parseMorningRoutines(List routines) => routines
      .map((routine) => ActivityItem(
            title: routine['activity'] as String,
            time: routine['time'] as String,
            kcal: routine['calories'] as String,
            type: ActivityType.activity,
          ))
      .toList();

  List<ActivityItem> _parseExercises(List exercises) => exercises
      .map((exercise) => ActivityItem(
            title: exercise['type'] as String,
            time: exercise['time'] as String,
            kcal: exercise['calories'] as String,
            type: ActivityType.activity,
          ))
      .toList();

  List<ActivityItem> _parseMeals(List meals) => meals
      .map((meal) => ActivityItem(
            title: meal['type'] as String,
            time: meal['time'] as String,
            kcal: meal['calories'] as String,
            type: ActivityType.meal,
            mealItems: _parseMealItems(meal),
          ))
      .toList();

  List<MealItem> _parseMealItems(dynamic meal) => (meal['menu'] as List)
      .map((item) => MealItem(
            name: item as String,
            kcal: meal['calories'] as String,
          ))
      .toList();
}
