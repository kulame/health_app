import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/gpt_service.dart';

part 'gpt_service_provider.g.dart';

@riverpod
GptService gptService(GptServiceRef ref) => GptService();
