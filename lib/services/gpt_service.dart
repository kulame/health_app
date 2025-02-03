import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GptService {
  final Dio _dio = Dio();
  final String _apiKey = dotenv.env['GPT_API_KEY'] ?? '';
  final String _apiEndpoint = dotenv.env['GPT_API_ENDPOINT'] ?? '';
  final String _model = dotenv.env['GPT_MODEL'] ?? 'gpt-4o';
  final int _maxTokens = int.parse(dotenv.env['GPT_MAX_TOKENS'] ?? '2000');
  final double _temperature =
      double.parse(dotenv.env['GPT_TEMPERATURE'] ?? '0.3');

  Future<String> extractTextFromPdf(File pdfFile) async {
    final PdfDocument document =
        PdfDocument(inputBytes: await pdfFile.readAsBytes());
    String text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  Future<Map<String, dynamic>> analyzeHealthReport(String pdfText) async {
    try {
      final response = await _dio.post(
        _apiEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''你是一个医疗康复专家。请分析以下医疗报告，并制定一天的康复计划。
                返回JSON格式，必须包含以下结构：
                {
                  "healthStatus": {
                    "bloodPressure": "血压值",
                    "bloodSugar": "血糖值",
                    "cholesterol": "胆固醇值",
                    "heartRate": "心率",
                    "otherIndicators": ["其他重要指标"]
                  },
                  "dailyPlan": {
                    "morningRoutine": [
                      {
                        "time": "具体时间",
                        "activity": "活动名称",
                        "duration": "持续时间",
                        "calories": "消耗卡路里",
                        "notes": "注意事项"
                      }
                    ],
                    "meals": [
                      {
                        "time": "用餐时间",
                        "type": "餐类型",
                        "menu": ["具体食物"],
                        "calories": "摄入卡路里",
                        "nutritionTips": "营养建议"
                      }
                    ],
                    "exercises": [
                      {
                        "time": "锻炼时间",
                        "type": "运动类型",
                        "intensity": "运动强度",
                        "duration": "持续时间",
                        "calories": "消耗卡路里",
                        "precautions": "注意事项"
                      }
                    ],
                    "medications": [
                      {
                        "time": "服药时间",
                        "name": "药品名称",
                        "dosage": "剂量",
                        "notes": "服药说明"
                      }
                    ]
                  },
                  "recommendations": {
                    "lifestyle": ["生活方式建议"],
                    "diet": ["饮食建议"],
                    "exercise": ["运动建议"],
                    "followUp": "后续就医建议"
                  }
                }
                '''
            },
            {'role': 'user', 'content': pdfText}
          ],
          'max_tokens': _maxTokens,
          'temperature': _temperature,
        },
      );

      developer.log('GPT-4O API Response:', error: {
        'statusCode': response.statusCode,
        'headers': response.headers,
        'data': response.data,
      });

      if (response.data['error'] != null) {
        throw Exception(response.data['error']['message']);
      }

      final result = response.data;
      developer.log('Parsed Health Report:', error: result);

      return result;
    } catch (e) {
      developer.log('Error in analyzeHealthReport:', error: e);
      throw Exception('分析报告失败: $e');
    }
  }
}
