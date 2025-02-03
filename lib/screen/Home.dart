import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/activity_provider.dart';
import '../models/activity_item.dart';
import '../providers/health_report_provider.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthReport = ref.watch(healthReportProvider);

    return healthReport.when(
      data: (report) {
        if (report == null) {
          return const Scaffold(
            body: Center(child: Text('没有健康报告数据')),
          );
        }

        try {
          // 获取 GPT 返回的 content
          final content = report['choices'][0]['message']['content'] as String;
          developer.log('Raw GPT response:', error: content); // 添加日志

          // 清理和格式化 JSON 字符串
          final cleanContent = content
              .trim()
              .replaceAll(
                  RegExp(r'^\s*```json\s*|\s*```\s*$'), '') // 移除可能的 JSON 标记
              .replaceAll(RegExp(r'[\u{200B}-\u{200D}\u{FEFF}]'), ''); // 移除零宽字符

          // 解析 JSON 字符串为 Map
          final dailyPlan = jsonDecode(cleanContent) as Map<String, dynamic>;
          developer.log('Parsed JSON:', error: dailyPlan); // 添加日志

          // 更新活动列表
          ref.read(activitiesProvider.notifier).updateFromReport(dailyPlan);
        } catch (e, stack) {
          developer.log('Data parsing error:', error: e, stackTrace: stack);
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('数据解析错误'),
                  if (report['choices']?[0]?['message']?['content'] != null)
                    SelectableText(
                      report['choices'][0]['message']['content'].toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  Text(e.toString()),
                ],
              ),
            ),
          );
        }

        // 显示活动列表
        final activities = ref.watch(activitiesProvider);

        return Scaffold(
          backgroundColor: const Color.fromRGBO(21, 17, 20, 1),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 45),
                    Container(
                      width: double.infinity,
                      height: 129,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(35, 35, 37, 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wednesday',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'October 9, 2024',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: List.generate(7, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 14.0),
                                  child: Container(
                                    width: 48,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: index == 2
                                          ? Color.fromRGBO(21, 17, 20, 1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${7 + index}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          [
                                            'Mon',
                                            'Tue',
                                            'Wed',
                                            'Thr',
                                            'Fri',
                                            'Sat',
                                            'Sun'
                                          ][index],
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ...activities.map((activity) {
                      if (activity.type == ActivityType.meal) {
                        return _buildMealSection(
                          activity.title,
                          activity.time,
                          activity.mealItems
                                  ?.map((item) =>
                                      _buildMealItem(item.name, item.kcal))
                                  .toList() ??
                              [],
                        );
                      } else {
                        return _buildActivitySection(
                          activity.title,
                          activity.time,
                          activity.kcal,
                        );
                      }
                    }).toList(),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(35, 35, 37, 1),
                        borderRadius: BorderRadius.circular(46),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(55, 236, 203, 0.39),
                            offset: Offset(0, 4),
                            blurRadius: 14,
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(55, 236, 203, 1),
                            Color.fromRGBO(27, 137, 117, 1),
                            Color.fromRGBO(37, 198, 168, 1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Ask AI',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: <Color>[
                                  Colors.white,
                                  Colors.white.withOpacity(0.6),
                                ],
                              ).createShader(
                                  Rect.fromLTWH(0.0, 0.0, 50.0, 19.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('错误: $error')),
      ),
    );
  }

  Widget _buildActivitySection(String title, String time, String kcal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 62),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            kcal,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, String time, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 62),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMealItem(String name, String kcal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SizedBox(width: 78),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          Text(
            kcal,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
