import 'dart:io';
import 'package:openai_dart/openai_dart.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../models/activity_item.dart';

class GptService {
  final OpenAIClient _client;
  final Ref _ref;
  final String _modelId;

  GptService(this._ref)
      : _client = OpenAIClient(
          apiKey: dotenv.env['GPT_API_KEY'] ?? '',
        ),
        _modelId = dotenv.env['GPT_MODEL'] ?? 'gpt-4o';

  static const _healthPlanSchema = JsonSchemaObject(
    name: 'HealthPlan',
    description: '每日健康计划',
    strict: true,
    schema: {
      'type': 'object',
      'properties': {
        'dailyPlan': {
          'type': 'object',
          'required': ['morningRoutine', 'exercises', 'meals'],
          'properties': {
            'morningRoutine': {
              'type': 'array',
              'items': {
                'type': 'object',
                'required': ['time', 'activity', 'calories'],
                'properties': {
                  'time': {'type': 'string'},
                  'activity': {'type': 'string'},
                  'calories': {'type': 'string'}
                },
                'additionalProperties': false
              }
            },
            'exercises': {
              'type': 'array',
              'items': {
                'type': 'object',
                'required': ['time', 'type', 'calories'],
                'properties': {
                  'time': {'type': 'string'},
                  'type': {'type': 'string'},
                  'calories': {'type': 'string'}
                },
                'additionalProperties': false
              }
            },
            'meals': {
              'type': 'array',
              'items': {
                'type': 'object',
                'required': ['time', 'type', 'calories', 'menu'],
                'properties': {
                  'time': {'type': 'string'},
                  'type': {'type': 'string'},
                  'calories': {'type': 'string'},
                  'menu': {
                    'type': 'array',
                    'items': {'type': 'string'}
                  }
                },
                'additionalProperties': false
              }
            }
          },
          'additionalProperties': false
        }
      },
      'required': ['dailyPlan'],
      'additionalProperties': false
    },
  );

  Future<String> extractTextFromPdf(File pdfFile) async {
    final document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  Future<List<ActivityItem>> analyzeHealthReport(String pdfText) async {
    try {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_modelId),
          messages: [
            ChatCompletionMessage.system(
              content: '你是一个医疗康复专家。请分析以下医疗报告，并制定一天的康复计划。',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(pdfText),
            ),
          ],
          responseFormat: ResponseFormat.jsonSchema(
            jsonSchema: _healthPlanSchema,
          ),
          temperature: 0.3,
        ),
      );

      final rawData = jsonDecode(response.choices.first.message.content!)
          as Map<String, dynamic>;

      return _parseActivities(rawData);
    } catch (e) {
      throw Exception('分析报告失败: $e');
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

  Future<String> chat(String message) async {
    try {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_modelId),
          messages: [
            ChatCompletionMessage.system(
              content: '你是一个友好的健康顾问。请用简洁专业的语言回答用户的问题。',
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(message),
            ),
          ],
          temperature: 0.7,
        ),
      );

      return response.choices.first.message.content ?? '抱歉，我现在无法回答这个问题。';
    } catch (e) {
      throw Exception('聊天失败: $e');
    }
  }

  Future<void> saveHealthPlan(String response, DateTime date) async {
    try {
      final jsonResponse = jsonDecode(response);
      final plan = jsonResponse['dailyPlan'];

      final db = _ref.read(databaseProvider);
      await db.insertOrUpdateHealthPlan(
        date: date,
        morningRoutine: jsonEncode(plan['morningRoutine']),
        exercises: jsonEncode(plan['exercises']),
        meals: jsonEncode(plan['meals']),
      );
    } catch (e) {
      throw Exception('保存健康计划失败: $e');
    }
  }
}
