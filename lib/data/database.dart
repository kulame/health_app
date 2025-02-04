import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:drift/native.dart';

part 'database.g.dart';

class DailyHealthPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
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
  int get schemaVersion => 1;

  Future<DailyHealthPlan?> getHealthPlanByDate(DateTime date) {
    final query = select(dailyHealthPlans)
      ..where((plan) => plan.date.equals(date));
    return query.getSingleOrNull();
  }

  Future<int> insertOrUpdateHealthPlan({
    required DateTime date,
    required String morningRoutine,
    required String exercises,
    required String meals,
  }) async {
    return into(dailyHealthPlans).insertOnConflictUpdate(
      DailyHealthPlansCompanion.insert(
        date: date,
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
    final file = File(p.join(dbFolder.path, 'health_plans.db'));
    return NativeDatabase.createInBackground(file);
  });
}
