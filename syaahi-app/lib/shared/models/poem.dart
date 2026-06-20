enum PoemLanguage { english, hindi, urdu }

enum PoemEmotion { love, longing, hope, solitude, anger, gratitude }

extension PoemLanguageX on PoemLanguage {
  String get apiValue => name.toUpperCase();
  String get label => switch (this) {
        PoemLanguage.english => 'English',
        PoemLanguage.hindi => 'हिन्दी',
        PoemLanguage.urdu => 'اردو',
      };

  static PoemLanguage fromApi(String value) =>
      PoemLanguage.values.firstWhere((e) => e.apiValue == value.toUpperCase(),
          orElse: () => PoemLanguage.english);
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
        PoemEmotion.love => '❤️',
        PoemEmotion.longing => '🌙',
        PoemEmotion.hope => '🌱',
        PoemEmotion.solitude => '🕊️',
        PoemEmotion.anger => '🔥',
        PoemEmotion.gratitude => '⭐',
      };

  static PoemEmotion? fromApi(String? value) {
    if (value == null) return null;
    try {
      return PoemEmotion.values
          .firstWhere((e) => e.apiValue == value.toUpperCase());
    } catch (_) {
      return null;
    }
  }
}

class PoemAuthor {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  const PoemAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory PoemAuthor.fromJson(Map<String, dynamic> json) => PoemAuthor(
        id: json['id'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

class Poem {
  final String id;
  final String? title;
  final String content;
  final PoemLanguage language;
  final PoemEmotion? emotion;
  final String? theme;
  final PoemAuthor author;
  final DateTime createdAt;

  const Poem({
    required this.id,
    required this.title,
    required this.content,
    required this.language,
    required this.emotion,
    required this.theme,
    required this.author,
    required this.createdAt,
  });

  factory Poem.fromJson(Map<String, dynamic> json) => Poem(
        id: json['id'] as String,
        title: json['title'] as String?,
        content: json['content'] as String,
        language: PoemLanguageX.fromApi(json['language'] as String),
        emotion: PoemEmotionX.fromApi(json['emotion'] as String?),
        theme: json['theme'] as String?,
        author: PoemAuthor.fromJson(json['author'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}