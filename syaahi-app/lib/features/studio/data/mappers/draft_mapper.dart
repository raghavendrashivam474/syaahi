import 'package:drift/drift.dart';
import '../../../../shared/models/poem.dart';
import '../../domain/models/draft_poem.dart';
import '../local/studio_database.dart';

class DraftMapper {
  static DraftPoem fromLocal(LocalDraftData data) {
    return DraftPoem(
      id: data.id,
      ownerId: data.ownerId,
      title: data.title,
      content: data.content,
      language: PoemLanguageX.fromApi(data.language),
      emotion: PoemEmotionX.fromApi(data.emotion),
      theme: data.theme,
      isPublished: data.isPublished,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == data.syncStatus,
        orElse: () => SyncStatus.localOnly,
      ),
      version: data.version,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  static LocalDraftsCompanion toLocalCompanion(DraftPoem draft) {
    return LocalDraftsCompanion(
      id: Value(draft.id),
      ownerId: Value(draft.ownerId),
      title: Value(draft.title),
      content: Value(draft.content),
      language: Value(draft.language.apiValue),
      emotion: Value(draft.emotion?.apiValue),
      theme: Value(draft.theme),
      isPublished: Value(draft.isPublished),
      syncStatus: Value(draft.syncStatus.name),
      version: Value(draft.version),
      createdAt: Value(draft.createdAt),
      updatedAt: Value(draft.updatedAt),
    );
  }

  static DraftPoem fromRemoteJson(Map<String, dynamic> json, String ownerId) {
    return DraftPoem(
      id: json['id'] as String,
      ownerId: ownerId,
      title: json['title'] as String?,
      content: json['content'] as String,
      language: PoemLanguageX.fromApi(json['language'] as String? ?? 'ENGLISH'),
      emotion: PoemEmotionX.fromApi(json['emotion'] as String?),
      theme: json['theme'] as String?,
      isPublished: json['isPublished'] as bool? ?? false,
      syncStatus: SyncStatus.synced,
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Map<String, dynamic> toRemoteJson(DraftPoem draft) {
    return {
      'id': draft.id,
      'title': draft.title,
      'content': draft.content,
      'language': draft.language.apiValue,
      'emotion': draft.emotion?.apiValue,
      'theme': draft.theme,
      'version': draft.version,
    };
  }
}
