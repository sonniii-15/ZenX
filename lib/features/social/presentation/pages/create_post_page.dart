import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';

import '../../../../core/theme/zenx_colors.dart';
import '../../domain/models/social_post.dart';
import '../providers/social_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gamification/presentation/providers/user_profile_provider.dart';
import '../widgets/social_post_card.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  final Duration? duration;
  final double? distanceKm;
  final List<LatLng>? routeCoordinates;
  final int? gpsPointCount;
  final int? capturedCellsCount;
  final double? territoryAreaSqKm;
  final bool? isLoopCompleted;
  final int? earnedPoints;
  final double? averageSpeedKmh;
  final double? estimatedCalories;

  const CreatePostPage({
    super.key,
    this.duration,
    this.distanceKm,
    this.routeCoordinates,
    this.gpsPointCount,
    this.capturedCellsCount,
    this.territoryAreaSqKm,
    this.isLoopCompleted,
    this.earnedPoints,
    this.averageSpeedKmh,
    this.estimatedCalories,
  });

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _captionController = TextEditingController();
  String? _activityPhotoLocalPath;
  bool _isPublishing = false;

  bool get _isActivityPost => widget.duration != null && widget.duration != Duration.zero;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _activityPhotoLocalPath = pickedFile.path;
      });
    }
  }

  Future<void> _publishPost() async {
    final user = ref.read(authStateProvider).valueOrNull;
    final userProfile = ref.read(userProfileProvider).valueOrNull;
    
    if (user == null || userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated or profile missing.'), backgroundColor: ZenXColors.error),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final post = SocialPost(
        id: '',
        userId: user.uid,
        username: userProfile.username,
        profileImageUrl: user.photoURL,
        avatarLocalPath: userProfile.avatarLocalPath,
        caption: _captionController.text.trim(),
        distanceKm: widget.distanceKm ?? 0.0,
        duration: widget.duration ?? Duration.zero,
        points: widget.earnedPoints ?? 0,
        capturedCellsCount: widget.capturedCellsCount ?? 0,
        averageSpeedKmh: widget.averageSpeedKmh ?? 0.0,
        estimatedCalories: widget.estimatedCalories ?? 0.0,
        activityPhotoLocalPath: _activityPhotoLocalPath,
        createdAt: DateTime.now(),
        routeCoordinates: widget.routeCoordinates ?? [],
      );

      await ref.read(socialRepositoryProvider).createPost(post);
      ref.invalidate(feedProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published!'), backgroundColor: ZenXColors.primary),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing: $e'), backgroundColor: ZenXColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEW POST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isPublishing ? null : _publishPost,
            child: _isPublishing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: ZenXColors.primary, strokeWidth: 2))
                : const Text('PUBLISH', style: TextStyle(color: ZenXColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: _isActivityPost ? 'How was your workout?' : 'Share something with the community...',
                hintStyle: const TextStyle(color: ZenXColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: ZenXColors.surface,
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              enabled: !_isPublishing,
            ),
            const SizedBox(height: 16),
            
            if (_activityPhotoLocalPath != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_activityPhotoLocalPath!),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _activityPhotoLocalPath = null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _isPublishing ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZenXColors.primary,
                  side: const BorderSide(color: ZenXColors.primary),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isActivityPost) ...[
              const Text('Activity Attached', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              // We'll show a preview using a non-interactive mockup of the post card
              IgnorePointer(
                child: Opacity(
                  opacity: 0.8,
                  child: SocialPostCard(
                    post: SocialPost(
                      id: 'preview',
                      userId: '',
                      username: 'You',
                      caption: '',
                      distanceKm: widget.distanceKm ?? 0.0,
                      duration: widget.duration ?? Duration.zero,
                      points: widget.earnedPoints ?? 0,
                      capturedCellsCount: widget.capturedCellsCount ?? 0,
                      averageSpeedKmh: widget.averageSpeedKmh ?? 0.0,
                      estimatedCalories: widget.estimatedCalories ?? 0.0,
                      createdAt: DateTime.now(),
                      routeCoordinates: widget.routeCoordinates ?? [],
                    ),
                    isPreview: true, // we'll add this flag to SocialPostCard
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
