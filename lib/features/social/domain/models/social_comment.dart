class SocialComment {
  final String id;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final String text;
  final DateTime createdAt;

  const SocialComment({
    required this.id,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.text,
    required this.createdAt,
  });

  SocialComment copyWith({
    String? id,
    String? userId,
    String? username,
    String? profileImageUrl,
    String? text,
    DateTime? createdAt,
  }) {
    return SocialComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialComment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
