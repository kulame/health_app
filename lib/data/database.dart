import 'dart:developer' as developer;
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:drift/native.dart';
import 'package:intl/intl.dart';

part 'database.g.dart';

class DailyHealthPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get morningRoutine => text()();
  TextColumn get exercises => text()();
  TextColumn get meals => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [DailyHealthPlans])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  Future<DailyHealthPlan?> getHealthPlanByDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final query = select(dailyHealthPlans)
      ..where((plan) => plan.date.equals(dateStr));
    return query.getSingleOrNull();
  }

  Future<int> insertOrUpdateHealthPlan({
    required DateTime date,
    required String morningRoutine,
    required String exercises,
    required String meals,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return into(dailyHealthPlans).insertOnConflictUpdate(
      DailyHealthPlansCompanion.insert(
        date: dateStr,
        morningRoutine: morningRoutine,
        exercises: exercises,
        meals: meals,
        updatedAt: Value(DateTime.now()),
      ),
    );
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
