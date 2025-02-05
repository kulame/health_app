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

  GptService(this._ref)
      : _client = OpenAIClient(
          apiKey: dotenv.env['GPT_API_KEY'] ?? '',
        );

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
                  'time': {
                    'type': 'string',
                    'pattern': r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$'
                  },
                  'activity': {'type': 'string'},
                  'calories': {
                    'type': 'string',
                    'pattern': r'^[+-]? ?[0-9]+ Kcal$'
                  }
                }
              }
            },
            'exercises': {
              'type': 'array',
              'items': {
                'type': 'object',
                'required': ['time', 'type', 'calories'],
                'properties': {
                  'time': {
                    'type': 'string',
                    'pattern': r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$'
                  },
                  'type': {'type': 'string'},
                  'calories': {'type': 'string', 'pattern': r'^- ?[0-9]+ Kcal$'}
                }
              }
            },
            'meals': {
              'type': 'array',
              'items': {
                'type': 'object',
                'required': ['time', 'type', 'calories', 'menu'],
                'properties': {
                  'time': {
                    'type': 'string',
                    'pattern': r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$'
                  },
                  'type': {'type': 'string'},
                  'calories': {
                    'type': 'string',
                    'pattern': r'^\\+ ?[0-9]+ Kcal$'
                  },
                  'menu': {
                    'type': 'array',
                    'items': {'type': 'string'}
                  }
                }
              }
            }
          }
        }
      },
      'required': ['dailyPlan']
    },
  );

  Future<String> extractTextFromPdf(File pdfFile) async {
    final document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  Future<Map<String, dynamic>> analyzeHealthReport(String pdfText) async {
    try {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-4'),
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

      return jsonDecode(response.choices.first.message.content!)
          as Map<String, dynamic>;
    } catch (e) {
      throw Exception('分析报告失败: $e');
    }
  }

  Future<String> chat(String message) async {
    try {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('gpt-4'),
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
