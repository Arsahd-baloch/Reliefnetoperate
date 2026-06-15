import 'package:drift/drift.dart';

class LocalTasks extends Table {
  IntColumn get id => integer()();
  IntColumn get campaignId => integer().nullable()();
  IntColumn get beneficiaryId => integer().nullable()();
  IntColumn get createdBy => integer().nullable()();
  IntColumn get claimedBy => integer().nullable()();
  IntColumn get coordinatorId => integer().nullable()();
  TextColumn get sourceType => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get familySize => integer().withDefault(const Constant(1))();
  TextColumn get itemsNeeded => text()(); // Store as JSON string
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get locationText => text().nullable()();
  IntColumn get radiusKm => integer().withDefault(const Constant(5))();
  RealColumn get budgetPkr => real().withDefault(const Constant(0))();
  TextColumn get urgency => text()();
  TextColumn get status => text()();
  IntColumn get upvotes => integer().withDefault(const Constant(0))();
  IntColumn get downvotes => integer().withDefault(const Constant(0))();
  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  TextColumn get createdAt => text().nullable()();
  TextColumn get updatedAt => text().nullable()();
  TextColumn get claimedAt => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()();
  TextColumn get payload => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

