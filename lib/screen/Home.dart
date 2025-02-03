import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/activity_provider.dart';
import '../models/activity_item.dart';
import '../providers/health_report_provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthReport = ref.watch(healthReportProvider);

    return healthReport.when(
      data: (activities) {
        if (activities?.isEmpty ?? true) {
          return const Scaffold(
            body: Center(child: Text('没有健康报告数据')),
          );
        }

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 56, 33, 50),
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
                              DateFormat('EEEE').format(DateTime.now()),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat('MMMM d, y').format(DateTime.now()),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildWeekDays(),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('数据解析错误'),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
        ),
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

  Widget _buildWeekDays() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return Row(
      children: List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        final isToday = date.day == now.day;

        return Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: Container(
            width: 48,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isToday ? Color.fromRGBO(21, 17, 20, 1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('E').format(date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
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
    );
  }
}
