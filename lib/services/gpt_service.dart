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
    name: 'ActivityItems',
    description: '每日活动计划列表',
    strict: true,
    schema: {
      'type': 'object',
      'properties': {
        'activities': {
          'type': 'array',
          'items': {
            'type': 'object',
            'required': ['title', 'time', 'kcal', 'type'],
            'properties': {
              'title': {'type': 'string'},
              'time': {'type': 'string'},
              'kcal': {'type': 'string'},
              'type': {
                'type': 'string',
                'enum': ['activity', 'meal']
              },
              'mealItems': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'required': ['name', 'kcal'],
                  'properties': {
                    'name': {'type': 'string'},
                    'kcal': {'type': 'string'}
                  },
                  'additionalProperties': false
                }
              }
            },
            'additionalProperties': false
          }
        }
      },
      'required': ['activities'],
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
              content: '''你是一个医疗康复专家。请分析以下医疗报告，并制定一天的康复计划。
              返回的活动列表应包含：
              - 晨间活动（type: activity）
              - 运动计划（type: activity）
              - 餐食安排（type: meal，需包含 mealItems）
              所有时间格式为 HH:mm，卡路里格式为 "+/-数字 Kcal"''',
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

      final activities = (rawData['activities'] as List)
          .map((item) => ActivityItem(
                title: item['title'] as String,
                time: item['time'] as String,
                kcal: item['kcal'] as String,
                type: ActivityType.values.firstWhere(
                  (t) => t.toString().split('.').last == item['type'],
                ),
                mealItems: item['type'] == 'meal'
                    ? (item['mealItems'] as List)
                        .map((m) => MealItem(
                              name: m['name'] as String,
                              kcal: m['kcal'] as String,
                            ))
                        .toList()
                    : null,
              ))
          .toList();

      return activities;
    } catch (e) {
      throw Exception('分析报告失败: $e');
    }
  }

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
