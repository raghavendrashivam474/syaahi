enum PoemLanguage { english, hindi, urdu }

enum PoemEmotion { love, longing, hope, solitude, anger, gratitude }

enum ReactionType {
  feltThis,
  stayedWithMe,
  beautifullyWritten,
  madeMeThink,
  comfortedMe,
  inspiredMe,
}

extension PoemLanguageX on PoemLanguage {
  String get apiValue => name.toUpperCase();
  String get label => switch (this) {
        PoemLanguage.english => 'English',
        PoemLanguage.hindi => 'हिन्दी',
        PoemLanguage.urdu => 'اردو',
      };

  static PoemLanguage fromApi(String value) =>
      PoemLanguage.values.firstWhere(
        (e) => e.apiValue == value.toUpperCase(),
        orElse: () => PoemLanguage.english,
      );
}

extension PoemEmotionX on PoemEmotion {
  String get apiValue => name.toUpperCase();
  String get label => switch (this) {
        PoemEmotion.love => 'Love',
        PoemEmotion.longing => 'Longing',
        PoemEmotion.hope => 'Hope',
        PoemEmotion.solitude => 'Solitude',
        PoemEmotion.anger => 'Anger',
        PoemEmotion.gratitude => 'Gratitude',
      };

  String get emoji => switch (this) {
        PoemEmotion.love => '❤',
        PoemEmotion.longing => '🌙',
        PoemEmotion.hope => '🌱',
        PoemEmotion.solitude => '🕊️',
        PoemEmotion.anger => '🔥',
        PoemEmotion.gratitude => '✨',
      };

  static PoemEmotion? fromApi(String? value) {
    if (value == null) return null;
    return PoemEmotion.values.firstWhere(
      (e) => e.apiValue == value.toUpperCase(),
      orElse: () => PoemEmotion.love,
    );
  }
}

extension ReactionTypeX on ReactionType {
  String get apiValue => switch (this) {
        ReactionType.feltThis => 'FELT_THIS',
        ReactionType.stayedWithMe => 'STAYED_WITH_ME',
        ReactionType.beautifullyWritten => 'BEAUTIFULLY_WRITTEN',
        ReactionType.madeMeThink => 'MADE_ME_THINK',
        ReactionType.comfortedMe => 'COMFORTED_ME',
        ReactionType.inspiredMe => 'INSPIRED_ME',
      };

  String get label => switch (this) {
        ReactionType.feltThis => 'I Felt This',
        ReactionType.stayedWithMe => 'This Stayed With Me',
        ReactionType.beautifullyWritten => 'Beautifully Written',
        ReactionType.madeMeThink => 'Made Me Think',
        ReactionType.comfortedMe => 'Comforted Me',
        ReactionType.inspiredMe => 'Inspired Me',
      };

  static ReactionType? fromApi(String? value) {
    if (value == null) return null;
    return ReactionType.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => ReactionType.feltThis,
    );
  }
}

class ReactionSummary {
  final ReactionType type;
  final String label;
  final int count;
  final bool reacted;

  const ReactionSummary({
    required this.type,
    required this.label,
    required this.count,
    required this.reacted,
  });

  factory ReactionSummary.fromJson(Map<String, dynamic> json) {
    return ReactionSummary(
      type: ReactionTypeX.fromApi(json['type'] as String?) ?? ReactionType.feltThis,
      label: json['label'] as String,
      count: json['count'] as int,
      reacted: json['reacted'] as bool,
    );
  }
}

class PoemAuthor {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;

  const PoemAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
  });

  factory PoemAuthor.fromJson(Map<String, dynamic> json) {
    return PoemAuthor(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
    );
  }
}

class Poem {
  final String id;
  final String? title;
  final String content;
  final PoemLanguage language;
  final PoemEmotion? emotion;
  final String? theme;
  final PoemAuthor author;
  final int reactionCount;
  final int heartCount;
  final DateTime createdAt;

  const Poem({
    required this.id,
    this.title,
    required this.content,
    required this.language,
    this.emotion,
    this.theme,
    required this.author,
    required this.reactionCount,
    required this.heartCount,
    required this.createdAt,
  });

  factory Poem.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    return Poem(
      id: json['id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String,
      language: PoemLanguageX.fromApi(json['language'] as String? ?? 'ENGLISH'),
      emotion: PoemEmotionX.fromApi(json['emotion'] as String?),
      theme: json['theme'] as String?,
      author: PoemAuthor.fromJson(json['author'] as Map<String, dynamic>),
      reactionCount: count?['reactions'] as int? ?? 0,
      heartCount: count?['hearts'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}