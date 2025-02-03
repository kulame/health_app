import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../services/gpt_service.dart';

part 'health_report_provider.g.dart';

@riverpod
class HealthReport extends _$HealthReport {
  @override
  AsyncValue<Map<String, dynamic>?> build() => const AsyncValue.data(null);

  Future<void> analyzeReport(File file) async {
    state = const AsyncValue.loading();
    try {
      final gptService = GptService();
      final pdfText = await gptService.extractTextFromPdf(file);
      final analysisResult = await gptService.analyzeHealthReport(pdfText);
      state = AsyncValue.data(analysisResult);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
