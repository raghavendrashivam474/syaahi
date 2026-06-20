class User {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? bio;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'displayName': displayName,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };
}