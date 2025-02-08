// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DailyHealthPlansTable extends DailyHealthPlans
    with TableInfo<$DailyHealthPlansTable, DailyHealthPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyHealthPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activitiesMeta =
      const VerificationMeta('activities');
  @override
  late final GeneratedColumn<String> activities = GeneratedColumn<String>(
      'activities', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, activities, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_health_plans';
  @override
  VerificationContext validateIntegrity(Insertable<DailyHealthPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('activities')) {
      context.handle(
          _activitiesMeta,
          activities.isAcceptableOrUnknown(
              data['activities']!, _activitiesMeta));
    } else if (isInserting) {
      context.missing(_activitiesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyHealthPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyHealthPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      activities: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activities'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailyHealthPlansTable createAlias(String alias) {
    return $DailyHealthPlansTable(attachedDatabase, alias);
  }
}

class DailyHealthPlan extends DataClass implements Insertable<DailyHealthPlan> {
  final int id;
  final String date;
  final String activities;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyHealthPlan(
      {required this.id,
      required this.date,
      required this.activities,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['activities'] = Variable<String>(activities);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyHealthPlansCompanion toCompanion(bool nullToAbsent) {
    return DailyHealthPlansCompanion(
      id: Value(id),
      date: Value(date),
      activities: Value(activities),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyHealthPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyHealthPlan(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      activities: serializer.fromJson<String>(json['activities']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'activities': serializer.toJson<String>(activities),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyHealthPlan copyWith(
          {int? id,
          String? date,
          String? activities,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DailyHealthPlan(
        id: id ?? this.id,
        date: date ?? this.date,
        activities: activities ?? this.activities,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailyHealthPlan copyWithCompanion(DailyHealthPlansCompanion data) {
    return DailyHealthPlan(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      activities:
          data.activities.present ? data.activities.value : this.activities,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthPlan(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('activities: $activities, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, activities, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyHealthPlan &&
          other.id == this.id &&
          other.date == this.date &&
          other.activities == this.activities &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyHealthPlansCompanion extends UpdateCompanion<DailyHealthPlan> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> activities;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DailyHealthPlansCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.activities = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyHealthPlansCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String activities,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : date = Value(date),
        activities = Value(activities);
  static Insertable<DailyHealthPlan> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? activities,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (activities != null) 'activities': activities,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyHealthPlansCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? activities,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DailyHealthPlansCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (activities.present) {
      map['activities'] = Variable<String>(activities.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthPlansCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('activities: $activities, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyHealthPlansTable dailyHealthPlans =
      $DailyHealthPlansTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dailyHealthPlans];
}

typedef $$DailyHealthPlansTableCreateCompanionBuilder
    = DailyHealthPlansCompanion Function({
  Value<int> id,
  required String date,
  required String activities,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DailyHealthPlansTableUpdateCompanionBuilder
    = DailyHealthPlansCompanion Function({
  Value<int> id,
  Value<String> date,
  Value<String> activities,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$DailyHealthPlansTableFilterComposer
    extends Composer<_$AppDatabase, $DailyHealthPlansTable> {
  $$DailyHealthPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activities => $composableBuilder(
      column: $table.activities, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DailyHealthPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyHealthPlansTable> {
  $$DailyHealthPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activities => $composableBuilder(
      column: $table.activities, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyHealthPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyHealthPlansTable> {
  $$DailyHealthPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get activities => $composableBuilder(
      column: $table.activities, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyHealthPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyHealthPlansTable,
    DailyHealthPlan,
    $$DailyHealthPlansTableFilterComposer,
    $$DailyHealthPlansTableOrderingComposer,
    $$DailyHealthPlansTableAnnotationComposer,
    $$DailyHealthPlansTableCreateCompanionBuilder,
    $$DailyHealthPlansTableUpdateCompanionBuilder,
    (
      DailyHealthPlan,
      BaseReferences<_$AppDatabase, $DailyHealthPlansTable, DailyHealthPlan>
    ),
    DailyHealthPlan,
    PrefetchHooks Function()> {
  $$DailyHealthPlansTableTableManager(
      _$AppDatabase db, $DailyHealthPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyHealthPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyHealthPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyHealthPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> activities = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailyHealthPlansCompanion(
            id: id,
            date: date,
            activities: activities,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required String activities,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DailyHealthPlansCompanion.insert(
            id: id,
            date: date,
            activities: activities,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyHealthPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyHealthPlansTable,
    DailyHealthPlan,
    $$DailyHealthPlansTableFilterComposer,
    $$DailyHealthPlansTableOrderingComposer,
    $$DailyHealthPlansTableAnnotationComposer,
    $$DailyHealthPlansTableCreateCompanionBuilder,
    $$DailyHealthPlansTableUpdateCompanionBuilder,
    (
      DailyHealthPlan,
      BaseReferences<_$AppDatabase, $DailyHealthPlansTable, DailyHealthPlan>
    ),
    DailyHealthPlan,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyHealthPlansTableTableManager get dailyHealthPlans =>
      $$DailyHealthPlansTableTableManager(_db, _db.dailyHealthPlans);
}
