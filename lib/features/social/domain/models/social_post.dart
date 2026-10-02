import 'package:latlong2/latlong.dart';

class SocialPost {
  final String id;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final String? avatarLocalPath;
  final String caption;
  final double distanceKm;
  final Duration duration;
  final int points;
  final int capturedCellsCount;
  final double averageSpeedKmh;
  final double estimatedCalories;
  final String? activityPhotoLocalPath;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  
  // For map preview
  final List<LatLng> routeCoordinates;

  const SocialPost({
    required this.id,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    this.avatarLocalPath,
    required this.caption,
    required this.distanceKm,
    required this.duration,
    required this.points,
    required this.capturedCellsCount,
    this.averageSpeedKmh = 0.0,
    this.estimatedCalories = 0.0,
    this.activityPhotoLocalPath,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.routeCoordinates = const [],
  });

  SocialPost copyWith({
    String? id,
    String? userId,
    String? username,
    String? profileImageUrl,
    String? avatarLocalPath,
    String? caption,
    double? distanceKm,
    Duration? duration,
    int? points,
    int? capturedCellsCount,
    double? averageSpeedKmh,
    double? estimatedCalories,
    String? activityPhotoLocalPath,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    List<LatLng>? routeCoordinates,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      caption: caption ?? this.caption,
      distanceKm: distanceKm ?? this.distanceKm,
      duration: duration ?? this.duration,
      points: points ?? this.points,
      capturedCellsCount: capturedCellsCount ?? this.capturedCellsCount,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      activityPhotoLocalPath: activityPhotoLocalPath ?? this.activityPhotoLocalPath,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPost && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
