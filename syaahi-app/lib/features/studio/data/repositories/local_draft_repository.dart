import 'package:drift/drift.dart';
import '../../domain/models/draft_poem.dart';
import '../local/studio_database.dart';
import '../mappers/draft_mapper.dart';

class LocalDraftRepository {
  final StudioDatabase _db;

  LocalDraftRepository(this._db);

  Future<void> saveDraft(DraftPoem draft) async {
    final companion = DraftMapper.toLocalCompanion(draft);
    await _db.into(_db.localDrafts).insertOnConflictUpdate(companion);
  }

  Future<DraftPoem?> getDraft(String id, String ownerId) async {
    final query = _db.select(_db.localDrafts)
      ..where((tbl) => tbl.id.equals(id) & tbl.ownerId.equals(ownerId));
    final result = await query.getSingleOrNull();
    return result != null ? DraftMapper.fromLocal(result) : null;
  }

  Future<List<DraftPoem>> listDrafts(String ownerId) async {
    final query = _db.select(_db.localDrafts)
      ..where((tbl) => tbl.ownerId.equals(ownerId) & tbl.isPublished.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);
    final results = await query.get();
    return results.map(DraftMapper.fromLocal).toList();
  }

  Future<void> deleteDraft(String id, String ownerId) async {
    final query = _db.delete(_db.localDrafts)
      ..where((tbl) => tbl.id.equals(id) & tbl.ownerId.equals(ownerId));
    await query.go();
  }

  Future<void> updateSyncStatus(String id, SyncStatus status) async {
    final query = _db.update(_db.localDrafts)..where((tbl) => tbl.id.equals(id));
    await query.write(LocalDraftsCompanion(syncStatus: Value(status.name)));
  }

  Stream<List<DraftPoem>> watchDrafts(String ownerId) {
    final query = _db.select(_db.localDrafts)
      ..where((tbl) => tbl.ownerId.equals(ownerId) & tbl.isPublished.equals(false))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);
    return query.watch().map((list) => list.map(DraftMapper.fromLocal).toList());
  }
}
