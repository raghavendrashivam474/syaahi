/// Public-only author profile model.
///
/// Contains only fields safe for public display.
/// Intentionally excludes [email], followers, and following counts.
///
/// Constructed from `GET /api/v1/users/:username`.
/// See also: [User] (auth/session model) and [PoemAuthor] (embedded in [Poem]).
class AuthorProfile {
  final String id;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final DateTime createdAt;
  final int poemCount;

  const AuthorProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
    this.poemCount = 0,
  });

  /// Parse from `GET /api/v1/users/:username` response.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "username": "...",
  ///   "displayName": "...",
  ///   "bio": "...",
  ///   "avatarUrl": "...",
  ///   "createdAt": "2025-01-01T00:00:00.000Z",
  ///   "_count": { "poems": 12, "followers": 0, "following": 0 }
  /// }
  /// ```
  factory AuthorProfile.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    return AuthorProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      poemCount: count?['poems'] as int? ?? 0,
    );
  }

  /// Convenience factory for the own-profile case where we already
  /// have a [User] object from [authProvider].
  ///
  /// [createdAt] and [poemCount] are not available on [User],
  /// so they receive safe defaults. The profile screen should
  /// prefer the API-fetched [AuthorProfile] when possible.
  factory AuthorProfile.fromUser({
    required String id,
    required String username,
    required String displayName,
    String? bio,
    String? avatarUrl,
  }) {
    return AuthorProfile(
      id: id,
      username: username,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(), // placeholder — API value preferred
      poemCount: 0, // placeholder — API value preferred
    );
  }

  /// First letter of displayName, uppercased, for avatar fallback.
  String get initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}
