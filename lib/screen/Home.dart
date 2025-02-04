import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_item.dart';
import '../providers/health_report_provider.dart';
import '../widgets/chat_dialog.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../providers/selected_date_provider.dart';
import '../providers/database_provider.dart';
import '../providers/day_health_report_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHealthPlan();
    });
  }

  Future<void> _initializeHealthPlan() async {
    final selectedDate = ref.read(selectedDateProvider);
    final date =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    await ref.read(dayHealthReportProvider.notifier).loadDayHealthPlan(date);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dayHealthReport = ref.watch(dayHealthReportProvider);

    return dayHealthReport.when(
      data: (activities) => _buildHomeScreen(context, activities),
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(error),
    );
  }

  Widget _buildHomeScreen(
      BuildContext context, List<ActivityItem>? activities) {
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
              children: [
                const SizedBox(height: 45),
                _buildDateHeader(),
                const SizedBox(height: 20),
                ...(activities?.map(_buildActivityItem).toList() ?? []),
                const SizedBox(height: 20),
                _buildAskAiButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() => Container(
        width: double.infinity,
        height: 129,
        decoration: _buildHeaderDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildDateText(),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: _buildWeekDays(),
              ),
            ],
          ),
        ),
      );

  BoxDecoration _buildHeaderDecoration() => BoxDecoration(
        color: const Color.fromRGBO(35, 35, 37, 1),
        borderRadius: BorderRadius.circular(16),
      );

  Widget _buildDateText() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE').format(DateTime.now()),
            style: _buildTextStyle(14, false),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMMM d, y').format(DateTime.now()),
            style: _buildTextStyle(11, true),
          ),
        ],
      );

  TextStyle _buildTextStyle(double size, bool isSecondary) => TextStyle(
        color: isSecondary ? Colors.white.withOpacity(0.6) : Colors.white,
        fontSize: size,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
      );

  Widget _buildActivityItem(ActivityItem activity) => activity.type ==
          ActivityType.meal
      ? _buildMealSection(
          activity.title, activity.time, _buildMealItems(activity.mealItems))
      : _buildActivitySection(activity.title, activity.time, activity.kcal);

  List<Widget> _buildMealItems(List<MealItem>? mealItems) =>
      mealItems?.map((item) => _buildMealItem(item.name, item.kcal)).toList() ??
      [];

  Widget _buildActivitySection(String title, String time, String kcal) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Text(time, style: _buildTextStyle(12, true)),
            const SizedBox(width: 62),
            Text(title, style: _buildTextStyle(18, false)),
            const Spacer(),
            Text(kcal, style: _buildTextStyle(14, false)),
          ],
        ),
      );

  Widget _buildMealSection(String title, String time, List<Widget> items) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(time, style: _buildTextStyle(12, true)),
                const SizedBox(width: 62),
                Text(title, style: _buildTextStyle(18, false)),
              ],
            ),
            const SizedBox(height: 10),
            ...items,
          ],
        ),
      );

  Widget _buildMealItem(String name, String kcal) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            const SizedBox(width: 78),
            Text(name, style: _buildTextStyle(14, false)),
            const Spacer(),
            Text(kcal, style: _buildTextStyle(14, false)),
          ],
        ),
      );

  Widget _buildWeekDays() {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    Widget buildDayItem(DateTime weekStart, int index, DateTime now) {
      final date = weekStart.add(Duration(days: index));
      final isSelected = date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      return GestureDetector(
        onTap: () {
          ref.read(selectedDateProvider.notifier).selectDate(date);
          _loadHealthPlan(date);
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8.0),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromRGBO(37, 195, 166, 1)
                : isToday
                    ? const Color.fromRGBO(21, 17, 20, 1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: const Color.fromRGBO(37, 195, 166, 1),
                    width: 2,
                  )
                : null,
          ),
          child: _buildDayContent(date),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            List.generate(7, (index) => buildDayItem(weekStart, index, now)),
      ),
    );
  }

  Widget _buildDayContent(DateTime date) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${date.day}',
            style: _buildTextStyle(14, false),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('E').format(date),
            style: _buildTextStyle(11, true),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildAskAiButton(BuildContext context) => GestureDetector(
        onTap: () => _showChatDialog(context),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: _buildAskAiButtonDecoration(),
          child: Center(
            child: Text(
              'Ask AI',
              style: _buildAskAiTextStyle(),
            ),
          ),
        ),
      );

  BoxDecoration _buildAskAiButtonDecoration() => BoxDecoration(
        color: const Color.fromRGBO(35, 35, 37, 1),
        borderRadius: BorderRadius.circular(46),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(55, 236, 203, 0.39),
            offset: Offset(0, 4),
            blurRadius: 14,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(55, 236, 203, 1),
            Color.fromRGBO(27, 137, 117, 1),
            Color.fromRGBO(37, 198, 168, 1),
          ],
        ),
      );

  TextStyle _buildAskAiTextStyle() => TextStyle(
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        foreground: Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.6),
            ],
          ).createShader(const Rect.fromLTWH(0.0, 0.0, 50.0, 19.0)),
      );

  void _showChatDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ChatDialog(),
      ),
    );
  }

  Widget _buildLoadingScreen() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );

  Widget _buildErrorScreen(Object error) => Scaffold(
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
      );

  void _loadHealthPlan(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    await ref
        .read(dayHealthReportProvider.notifier)
        .loadDayHealthPlan(normalizedDate);
  }
}
