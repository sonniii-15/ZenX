import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../providers/leaderboard_provider.dart';
import '../../domain/models/leaderboard_entry.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ZenXColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: ZenXColors.textSecondary,
          dividerColor: ZenXColors.surfaceHighlight.withValues(alpha: 0.2),
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Friends'),
            Tab(text: 'Nearby'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardList(leaderboardAsync),
          const Center(child: Text('Coming Soon', style: TextStyle(color: ZenXColors.textSecondary))),
          const Center(child: Text('Coming Soon', style: TextStyle(color: ZenXColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(AsyncValue<List<LeaderboardEntry>> leaderboardAsync) {
    return leaderboardAsync.when(
      data: (rawEntries) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: rawEntries.length,
          itemBuilder: (context, index) {
            final entry = rawEntries[index];
            final isTop3 = index < 3;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: entry.isCurrentUser ? ZenXColors.primary.withValues(alpha: 0.15) : ZenXColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: entry.isCurrentUser 
                      ? ZenXColors.primary 
                      : (isTop3 ? ZenXColors.surfaceHighlight.withValues(alpha: 0.3) : Colors.transparent),
                ),
              ),
              child: Row(
                children: [
                  // Rank Number
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getRankColor(index, entry.isCurrentUser),
                      ),
                    ),
                  ),
                  
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZenXColors.surfaceHighlight,
                      border: entry.isCurrentUser ? Border.all(color: ZenXColors.primary, width: 1.5) : null,
                    ),
                    child: const Icon(Icons.person, color: Colors.white70, size: 20),
                  ),
                  const SizedBox(width: 16),
                  
                  // Username
                  Expanded(
                    child: Text(
                      entry.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        color: entry.isCurrentUser ? ZenXColors.primary : Colors.white,
                      ),
                    ),
                  ),
                  
                  // Points
                  Text(
                    '${entry.points} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().slideX(begin: 0.05, duration: 400.ms);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: ZenXColors.primary)),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: ZenXColors.error))),
    );
  }

  Color _getRankColor(int index, bool isCurrentUser) {
    if (isCurrentUser) return ZenXColors.primary;
    if (index == 0) return Colors.amber; // Gold
    if (index == 1) return Colors.grey[400]!; // Silver
    if (index == 2) return Colors.brown[300]!; // Bronze
    return ZenXColors.textSecondary;
  }
}
