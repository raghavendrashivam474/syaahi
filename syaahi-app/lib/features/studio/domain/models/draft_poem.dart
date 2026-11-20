import '../../../../shared/models/poem.dart';

enum SyncStatus {
  localOnly,
  pendingSync,
  synced,
  syncFailed;

  String get label => switch (this) {
        SyncStatus.localOnly => 'Local',
        SyncStatus.pendingSync => 'Syncing...',
        SyncStatus.synced => 'Synced',
        SyncStatus.syncFailed => 'Sync Failed',
      };
}

class DraftPoem {
  final String id;
  final String ownerId;
  final String? title;
  final String content;
  final PoemLanguage language;
  final PoemEmotion? emotion;
  final String? theme;
  final bool isPublished;
  final SyncStatus syncStatus;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DraftPoem({
    required this.id,
    required this.ownerId,
    this.title,
    required this.content,
    this.language = PoemLanguage.english,
    this.emotion,
    this.theme,
    this.isPublished = false,
    this.syncStatus = SyncStatus.localOnly,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  DraftPoem copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? content,
    PoemLanguage? language,
    PoemEmotion? emotion,
    String? theme,
    bool? isPublished,
    SyncStatus? syncStatus,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftPoem(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      content: content ?? this.content,
      language: language ?? this.language,
      emotion: emotion ?? this.emotion,
      theme: theme ?? this.theme,
      isPublished: isPublished ?? this.isPublished,
      syncStatus: syncStatus ?? this.syncStatus,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
