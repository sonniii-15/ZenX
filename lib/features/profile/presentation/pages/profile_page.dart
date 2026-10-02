import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../../../../core/widgets/zenx_avatar.dart';
import '../../../gamification/presentation/providers/user_profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/activity_preference_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _showAvatarBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZenXColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose Avatar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAvatarOption(context, ref, 'assets/avatars/avatar_1.png'),
                  _buildAvatarOption(context, ref, 'assets/avatars/avatar_2.png'),
                  _buildAvatarOption(context, ref, 'assets/avatars/avatar_3.png'),
                  _buildAvatarOption(context, ref, 'assets/avatars/avatar_4.png'),
                ],
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Firebase Storage configuration and billing plan upgrade required to enable photo uploads.'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text('Upload Photo', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: ZenXColors.surfaceHighlight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showActivitySelectionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZenXColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Physical Exercise',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildActivityOption(context, ref, 'Running', Icons.directions_run),
              const SizedBox(height: 12),
              _buildActivityOption(context, ref, 'Walking', Icons.directions_walk),
              const SizedBox(height: 12),
              _buildActivityOption(context, ref, 'Cycling', Icons.directions_bike),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityOption(BuildContext context, WidgetRef ref, String title, IconData icon) {
    final currentSelection = ref.watch(activityPreferenceProvider);
    final isSelected = currentSelection == title;

    return GestureDetector(
      onTap: () {
        ref.read(activityPreferenceProvider.notifier).state = title;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? ZenXColors.primary.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ZenXColors.primary : ZenXColors.surfaceHighlight.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? ZenXColors.primary : Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? ZenXColors.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: ZenXColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(BuildContext context, WidgetRef ref, String assetPath) {
    return GestureDetector(
      onTap: () {
        ref.read(userProfileProvider.notifier).updateAvatar(assetPath);
        Navigator.pop(context);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ZenXColors.primary.withValues(alpha: 0.5), width: 2),
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: ZenXColors.error),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/splash');
              }
            },
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (userProfile) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: AnimateList(
            interval: 100.ms,
            effects: [const FadeEffect(duration: Duration(milliseconds: 400)), const SlideEffect(begin: Offset(0, 0.1), duration: Duration(milliseconds: 400))],
            children: [
              // HEADER PROFILE
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ZenXColors.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: ZenXColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                      child: ZenXAvatar(
                        radius: 50,
                        localImagePath: userProfile.avatarLocalPath,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAvatarBottomSheet(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: ZenXColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(userProfile.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text('Level ${userProfile.currentLevel} • Conqueror', style: const TextStyle(color: ZenXColors.textSecondary, fontSize: 14)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: ZenXColors.primary, size: 20),
                    const SizedBox(width: 4),
                    Text('${userProfile.totalPoints} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              // Level Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('XP Progress', style: TextStyle(color: ZenXColors.textSecondary, fontSize: 12)),
                  Text('${userProfile.totalPoints} / ${userProfile.pointsForNextLevel} pts', style: const TextStyle(color: ZenXColors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: userProfile.progressToNextLevel,
                backgroundColor: ZenXColors.surfaceHighlight.withValues(alpha: 0.3),
                color: ZenXColors.primary,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              
              const SizedBox(height: 40),
              
              // ACHIEVEMENTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View all', style: TextStyle(color: ZenXColors.textSecondary, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (userProfile.earnedBadges.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No achievements yet', style: TextStyle(color: ZenXColors.textSecondary)),
                ))
              else
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: userProfile.earnedBadges.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final badge = userProfile.earnedBadges[index];
                      return _buildBadge(badge.iconData, badge.title);
                    },
                  ),
                ),
                
              const SizedBox(height: 40),
              
              const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              
              // 2-Column Grid Layout for Statistics
              Row(
                children: [
                  Expanded(child: _buildGridStatCard(Icons.directions_run, '${userProfile.totalActivities}', 'Total Activities')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGridStatCard(Icons.map, userProfile.totalDistanceKm.toStringAsFixed(2), 'Total Km')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildGridStatCard(Icons.local_fire_department, '${userProfile.totalCalories.toStringAsFixed(0)} kcal', 'Calories')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGridStatCard(Icons.grid_view, '${userProfile.totalCapturedCells}', 'Territory')),
                ],
              ),

              const SizedBox(height: 40),

              // ACTIVITY SELECTION SECTION
              const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showActivitySelectionModal(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: ZenXColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ZenXColors.surfaceHighlight.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.fitness_center, color: ZenXColors.primary),
                          SizedBox(width: 16),
                          Text('Physical Exercise', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final pref = ref.watch(activityPreferenceProvider);
                              return Text(pref, style: const TextStyle(color: ZenXColors.textSecondary, fontSize: 14));
                            }
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, color: ZenXColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: ZenXColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: ZenXColors.error))),
      ),
    );
  }

  Widget _buildBadge(IconData iconData, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: ZenXColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(iconData, color: Colors.amber, size: 30),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGridStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZenXColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZenXColors.surfaceHighlight.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ZenXColors.primary, size: 24),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: ZenXColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
