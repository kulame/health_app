import 'dart:developer' as developer;
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';
import '../models/activity_item.dart';

part 'database.g.dart';

class DailyHealthPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get activities => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [DailyHealthPlans])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  Future<void> insertOrUpdateHealthPlan({
    required DateTime date,
    required List<ActivityItem> activities,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final activitiesJson = jsonEncode(
        activities.map((activity) => activity.toJson()).toList(),
      );

      await into(dailyHealthPlans).insertOnConflictUpdate(
        DailyHealthPlansCompanion.insert(
          date: dateStr,
          activities: activitiesJson,
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      throw Exception('保存健康计划失败: $e');
    }
  }

  Future<List<ActivityItem>?> getHealthPlanByDate(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final result = await (select(dailyHealthPlans)
            ..where((plan) => plan.date.equals(dateStr)))
          .getSingleOrNull();

      if (result == null || result.activities.isEmpty) {
        return null;
      }

      final List<dynamic> activitiesJson = jsonDecode(result.activities);
      return activitiesJson
          .map((json) => ActivityItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('获取健康计划失败: $e');
    }
  }

  Future<List<DailyHealthPlan>> getAllHealthPlans() {
    return select(dailyHealthPlans).get();
  }

  Future<int> deleteHealthPlan(int id) {
    return (delete(dailyHealthPlans)..where((plan) => plan.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, 'health_plans.db');
    final file = File(dbPath);

    developer.log('数据库路径: $dbPath');
    developer.log('数据库文件是否存在: ${file.existsSync()}');

    if (!file.existsSync()) {
      developer.log('创建新的数据库文件');
    } else {
      developer.log('使用现有数据库文件');
      developer.log('数据库文件大小: ${await file.length()} bytes');
    }

    return NativeDatabase.createInBackground(file);
  });
}
