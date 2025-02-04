import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class GptService {
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GPT_API_KEY'] ?? '';
  final String _apiEndpoint = dotenv.env['GPT_API_ENDPOINT'] ?? '';
  final String _model = dotenv.env['GPT_MODEL'] ?? 'gpt-4';
  final int _maxTokens = int.parse(dotenv.env['GPT_MAX_TOKENS'] ?? '2000');
  final double _temperature =
      double.parse(dotenv.env['GPT_TEMPERATURE'] ?? '0.3');

  Future<String> extractTextFromPdf(File pdfFile) async {
    final document = PdfDocument(inputBytes: await pdfFile.readAsBytes());
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  Future<Map<String, dynamic>> analyzeHealthReport(String pdfText) async {
    try {
      final response = await _sendGptRequest(pdfText);
      final content =
          _cleanJsonString(response.data['choices'][0]['message']['content']);
      final result = jsonDecode(content) as Map<String, dynamic>;
      _validateResponse(result);
      return result;
    } catch (e) {
      throw Exception('分析报告失败: $e');
    }
  }

  Future<Response> _sendGptRequest(String pdfText) => _dio.post(
        _apiEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: _buildRequestData(pdfText),
      );

  Map<String, dynamic> _buildRequestData(String pdfText) => {
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': _systemPrompt,
          },
          {
            'role': 'user',
            'content': pdfText,
          },
        ],
        'temperature': 0.3,
      };

  String get _systemPrompt => '''你是一个医疗康复专家。请分析以下医疗报告，并制定一天的康复计划。
    请严格按照以下JSON格式返回，不要添加任何其他内容：
    {
      "dailyPlan": {
        "morningRoutine": [{"time": "HH:MM AM/PM", "activity": "活动名称", "calories": "± XXX Kcal"}],
        "exercises": [{"time": "HH:MM AM/PM", "type": "运动名称", "calories": "- XXX Kcal"}],
        "meals": [{"time": "HH:MM AM/PM", "type": "餐食类型", "calories": "+ XXX Kcal", "menu": ["食物1", "食物2"]}]
      }
    }''';

  String _cleanJsonString(String input) {
    // 移除 JSON 代码块标记
    var cleaned = input.replaceAll(RegExp(r'```json|```'), '').trim();

    // 移除零宽字符和其他不可见字符
    cleaned = cleaned.replaceAll('\u200B', ''); // 零宽空格
    cleaned = cleaned.replaceAll('\u200C', ''); // 零宽非连接符
    cleaned = cleaned.replaceAll('\u200D', ''); // 零宽连接符
    cleaned = cleaned.replaceAll('\uFEFF', ''); // 字节顺序标记

    // 移除多余的空白字符
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  void _validateResponse(Map<String, dynamic> data) {
    if (!data.containsKey('dailyPlan')) {
      throw Exception('返回数据缺少 dailyPlan 字段');
    }

    final plan = data['dailyPlan'] as Map<String, dynamic>;

    if (!plan.containsKey('morningRoutine') ||
        !plan.containsKey('exercises') ||
        !plan.containsKey('meals')) {
      throw Exception('dailyPlan 缺少必要字段');
    }
  }
}
