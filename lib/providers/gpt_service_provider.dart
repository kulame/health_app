import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gpt_service.dart';

part 'gpt_service_provider.g.dart';

@riverpod
GptService gptService(Ref ref) => GptService(ref);
