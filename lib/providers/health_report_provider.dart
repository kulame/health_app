import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../models/activity_item.dart';
import 'dart:developer' as developer;
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

      developer.log('开始提取PDF文本');
      final pdfText = await gptService.extractTextFromPdf(file);
      developer.log('PDF文本提取完成，长度: ${pdfText.length}');

      developer.log('开始调用GPT服务解析健康报告');
      final activities = await gptService.analyzeHealthReport(pdfText);
      developer.log('GPT解析完成，活动数量: ${activities.length}');

      state = AsyncValue.data(activities);
    } catch (e, st) {
      developer.log(
        '健康报告解析失败',
        error: e,
        stackTrace: st,
        name: 'HealthReport',
      );

      // 构建详细的错误信息
      final errorMessage = StringBuffer()
        ..writeln('健康报告解析失败:')
        ..writeln('错误类型: ${e.runtimeType}')
        ..writeln('错误信息: $e')
        ..writeln('堆栈跟踪:')
        ..writeln(st.toString());

      developer.log(errorMessage.toString());

      // 更新状态时包含详细错误信息
      state = AsyncValue.error(
        errorMessage.toString(),
        st,
      );
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
