import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'local_task_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocalTasks, OutboxEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'disaster_aid_local'));

  @override
  int get schemaVersion => 1;
}
