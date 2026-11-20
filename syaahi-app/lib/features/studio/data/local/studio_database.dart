import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'studio_database.g.dart';

@DataClassName('LocalDraftData')
class LocalDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text()();
  TextColumn get language => text().withDefault(const Constant('ENGLISH'))();
  TextColumn get emotion => text().nullable()();
  TextColumn get theme => text().nullable()();
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('localOnly'))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalDrafts])
class StudioDatabase extends _$StudioDatabase {
  StudioDatabase([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 1;
}