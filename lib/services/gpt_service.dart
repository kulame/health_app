import 'dart:io';
import 'package:health_app/models/chat_message.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../models/activity_item.dart';
import 'dart:developer' as developer;
import '../utils/activity_item_utils.dart';

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
            'required': ['title', 'time', 'kcal', 'type', 'mealItems'],
            'additionalProperties': false
          }
        }
      },
      'required': ['activities'],
      'additionalProperties': false
    },
  );

  static const _savePlanFunction = FunctionObject(
    name: "insertOrUpdateHealthPlan",
    description: "save health plan to database",
    parameters: {
      'type': 'object',
      'properties': {
        'date': {
          'type': 'string',
          'description': 'the date of the health plan , format is yyyy-MM-dd',
        },
        'activities': {
          'type': 'array',
          'items': {
            'type': 'object',
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
            'required': ['title', 'time', 'kcal', 'type', 'mealItems'],
            'additionalProperties': false
          }
        }
      }
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
              - 晨间活动（type: activity，mealItems设为空数组[]）
              - 运动计划（type: activity，mealItems设为空数组[]）
              - 餐食安排（type: meal，mealItems包含具体餐食项）
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
                    : [], // 非 meal 类型返回空数组
              ))
          .toList();

      return activities;
    } catch (e) {
      throw Exception('分析报告失败: $e');
    }
  }

  Future<String> agent(
    String message,
    List<ChatMessage> history,
    List<ActivityItem> activities,
  ) async {
    const tool = ChatCompletionTool(
      type: ChatCompletionToolType.function,
      function: _savePlanFunction,
    );

    try {
      developer.log('开始处理聊天请求', name: 'GptService');
      developer.log('用户消息: $message', name: 'GptService');
      developer.log('历史消息数量: ${history.length}', name: 'GptService');

      final currentPlanMessage = activities.isNotEmpty
          ? '''
当前的健康计划如下：
${activities.map((a) => '''
- ${a.time} ${a.title} (${a.kcal})
  ${a.type == ActivityType.meal ? '包含: ${a.mealItems?.map((m) => "${m.name}(${m.kcal})").join(", ")}' : ''}
''').join()}
'''
          : null;

      final messages = [
        ChatCompletionMessage.system(
          content: '''你是一个友好的健康顾问。请用简洁专业的语言回答用户的问题。
          如果用户提到需要调整健康计划，请使用 insertOrUpdateHealthPlan 函数来保存新的计划。
          ${currentPlanMessage ?? '用户当前没有健康计划。'}''',
        ),
        ...history.map((msg) => msg.isUser
            ? ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(msg.message))
            : ChatCompletionMessage.assistant(content: msg.message)),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message),
        ),
      ];

      developer.log('发送请求到 GPT', name: 'GptService');
      developer.log('系统提示: ${messages.first.content}', name: 'GptService');
      developer.log(
          '历史消息: ${messages.skip(1).take(messages.length - 2).map((m) => '${m.role}: ${m.content}').toList()}',
          name: 'GptService');
      developer.log('当前消息: ${messages.last.content}', name: 'GptService');

      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_modelId),
          messages: messages,
          temperature: 0.7,
          tools: [tool],
          toolChoice: ChatCompletionToolChoiceOption.tool(
            ChatCompletionNamedToolChoice(
              type: ChatCompletionNamedToolChoiceType.function,
              function: ChatCompletionFunctionCallOption(
                  name: _savePlanFunction.name),
            ),
          ),
        ),
      );

      // 打印完整的响应数据
      developer.log('OpenAI 完整响应:', name: 'GptService');
      developer.log('ID: ${response.id}', name: 'GptService');
      developer.log('模型: ${response.model}', name: 'GptService');
      developer.log('使用tokens: ${response.usage?.totalTokens ?? 0}',
          name: 'GptService');
      developer.log('提示tokens: ${response.usage?.promptTokens ?? 0}',
          name: 'GptService');
      developer.log('完成tokens: ${response.usage?.completionTokens ?? 0}',
          name: 'GptService');

      final choice = response.choices.first;
      developer.log('选择索引: ${choice.index}', name: 'GptService');
      developer.log('结束原因: ${choice.finishReason}', name: 'GptService');
      developer.log('消息内容: ${choice.message}', name: 'GptService');

      if (choice.message.toolCalls != null) {
        for (final toolCall in choice.message.toolCalls!) {
          developer.log('工具调用ID: ${toolCall.id}', name: 'GptService');
          developer.log('工具类型: ${toolCall.type}', name: 'GptService');
          developer.log('函数名称: ${toolCall.function.name}', name: 'GptService');
          developer.log('函数参数: ${toolCall.function.arguments}',
              name: 'GptService');
        }
      }

      final toolCalls = choice.message.toolCalls;
      if (toolCalls != null && toolCalls.isNotEmpty) {
        developer.log('检测到函数调用', name: 'GptService');
        var after = activities;
        for (final toolCall in toolCalls) {
          if (toolCall.function.name == 'insertOrUpdateHealthPlan') {
            final arguments = jsonDecode(toolCall.function.arguments);
            developer.log('解析函数参数: $arguments', name: 'GptService');

            final date = DateTime.parse(arguments['date'] as String);
            developer.log('日期: $date', name: 'GptService');

            after = (arguments['activities'] as List)
                .map((item) =>
                    ActivityItem.fromJson(item as Map<String, dynamic>))
                .toList();
            developer.log('活动数量: ${after.length}', name: 'GptService');
            developer.log('活动详情: ${jsonEncode(after)}', name: 'GptService');

            final db = _ref.read(databaseProvider);
            developer.log('开始保存到数据库', name: 'GptService');
            await db.insertOrUpdateHealthPlan(
              date: date,
              activities: after,
            );
            developer.log('保存成功', name: 'GptService');
          }
        }
        return chatWithModified(message, history,
            before: activities, after: after);
      } else {
        developer.log('没有检测到函数调用', name: 'GptService');
        return chat(message, history, activities);
      }
    } catch (e, stack) {
      developer.log('聊天失败', name: 'GptService', error: e, stackTrace: stack);
      throw Exception('聊天失败: $e');
    }
  }

  Future<void> saveHealthPlan(String response, DateTime date) async {
    try {
      final jsonResponse = jsonDecode(response);
      final activities = (jsonResponse['activities'] as List)
          .map((item) => ActivityItem.fromJson(item as Map<String, dynamic>))
          .toList();

      final db = _ref.read(databaseProvider);
      await db.insertOrUpdateHealthPlan(
        date: date,
        activities: activities,
      );
    } catch (e) {
      throw Exception('保存健康计划失败: $e');
    }
  }

  Future<String> chat(
    String message,
    List<ChatMessage> history,
    List<ActivityItem> activities,
  ) async {
    try {
      developer.log('开始处理聊天请求', name: 'GptService');
      developer.log('用户消息: $message', name: 'GptService');
      developer.log('历史消息数量: ${history.length}', name: 'GptService');

      final currentPlanMessage = activities.isNotEmpty
          ? '''
当前的健康计划如下：
${ActivityItemUtils.formatToString(activities)}'''
          : null;

      final messages = [
        ChatCompletionMessage.system(
          content: '''你是一个友好的健康顾问。请用简洁专业的语言回答用户的问题。
          ${currentPlanMessage ?? '用户当前没有健康计划。'}''',
        ),
        ...history.map((msg) => msg.isUser
            ? ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(msg.message))
            : ChatCompletionMessage.assistant(content: msg.message)),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message),
        ),
      ];

      developer.log('发送请求到 GPT', name: 'GptService');
      developer.log('系统提示: ${messages.first.content}', name: 'GptService');
      developer.log(
          '历史消息: ${messages.skip(1).take(messages.length - 2).map((m) => '${m.role}: ${m.content}').toList()}',
          name: 'GptService');
      developer.log('当前消息: ${messages.last.content}', name: 'GptService');

      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_modelId),
          messages: messages,
          temperature: 0.7,
        ),
      );

      // 打印完整的响应数据
      developer.log('OpenAI 完整响应:', name: 'GptService');
      developer.log('ID: ${response.id}', name: 'GptService');
      developer.log('模型: ${response.model}', name: 'GptService');
      developer.log('使用tokens: ${response.usage?.totalTokens ?? 0}',
          name: 'GptService');
      developer.log('提示tokens: ${response.usage?.promptTokens ?? 0}',
          name: 'GptService');
      developer.log('完成tokens: ${response.usage?.completionTokens ?? 0}',
          name: 'GptService');

      final choice = response.choices.first;
      developer.log('选择索引: ${choice.index}', name: 'GptService');
      developer.log('结束原因: ${choice.finishReason}', name: 'GptService');
      developer.log('消息内容: ${choice.message}', name: 'GptService');

      final content = choice.message.content;
      developer.log('最终返回内容: $content', name: 'GptService');
      return content ?? '抱歉，我现在无法回答这个问题。';
    } catch (e, stack) {
      developer.log('聊天失败', name: 'GptService', error: e, stackTrace: stack);
      throw Exception('聊天失败: $e');
    }
  }

  Future<String> chatWithModified(String message, List<ChatMessage> history,
      {required List<ActivityItem> before,
      required List<ActivityItem> after}) async {
    try {
      developer.log('开始处理修改后的聊天请求', name: 'GptService');
      developer.log('用户消息: $message', name: 'GptService');
      developer.log('历史消息数量: ${history.length}', name: 'GptService');
      developer.log('修改前活动数量: ${before.length}', name: 'GptService');
      developer.log('修改后活动数量: ${after.length}', name: 'GptService');

      // 获取计划差异
      final diff = ActivityItemUtils.comparePlans(before, after);

      final planComparison = '''
修改前的健康计划：
${ActivityItemUtils.formatToString(before)}

修改后的健康计划：
${ActivityItemUtils.formatToString(after)}

主要变化：
${diff['added'].isNotEmpty ? '新增活动：\n${ActivityItemUtils.formatToString(diff['added'])}\n' : ''}
${diff['removed'].isNotEmpty ? '删除活动：\n${ActivityItemUtils.formatToString(diff['removed'])}\n' : ''}
${diff['modified'].isNotEmpty ? '修改活动：\n${(diff['modified'] as List).map((m) => '- ${m['old'].title} -> ${m['new'].title}').join('\n')}\n' : ''}
总卡路里变化：${diff['totalKcalDiff']} Kcal
''';

      final messages = [
        ChatCompletionMessage.system(
          content: '''你是一个友好的健康顾问。请用简洁专业的语言分析健康计划的变化。
          请根据修改前后的计划差异，详细解释：
          1. 修改的具体内容
          2. 修改的原因
          3. 预期达到的效果
          4. 对用户的建议

          $planComparison''',
        ),
        ...history.map((msg) => msg.isUser
            ? ChatCompletionMessage.user(
                content: ChatCompletionUserMessageContent.string(msg.message))
            : ChatCompletionMessage.assistant(content: msg.message)),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message),
        ),
      ];

      developer.log('发送请求到 GPT', name: 'GptService');
      developer.log('系统提示: ${messages.first.content}', name: 'GptService');
      developer.log(
          '历史消息: ${messages.skip(1).take(messages.length - 2).map((m) => '${m.role}: ${m.content}').toList()}',
          name: 'GptService');
      developer.log('当前消息: ${messages.last.content}', name: 'GptService');

      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId(_modelId),
          messages: messages,
          temperature: 0.7,
        ),
      );

      // 打印完整的响应数据
      developer.log('OpenAI 完整响应:', name: 'GptService');
      developer.log('ID: ${response.id}', name: 'GptService');
      developer.log('模型: ${response.model}', name: 'GptService');
      developer.log('使用tokens: ${response.usage?.totalTokens ?? 0}',
          name: 'GptService');
      developer.log('提示tokens: ${response.usage?.promptTokens ?? 0}',
          name: 'GptService');
      developer.log('完成tokens: ${response.usage?.completionTokens ?? 0}',
          name: 'GptService');

      final choice = response.choices.first;
      developer.log('选择索引: ${choice.index}', name: 'GptService');
      developer.log('结束原因: ${choice.finishReason}', name: 'GptService');
      developer.log('消息内容: ${choice.message}', name: 'GptService');

      final content = choice.message.content;
      developer.log('最终返回内容: $content', name: 'GptService');
      return content ?? '抱歉，我现在无法分析计划变化。';
    } catch (e, stack) {
      developer.log('分析计划变化失败',
          name: 'GptService', error: e, stackTrace: stack);
      throw Exception('分析计划变化失败: $e');
    }
  }
}
