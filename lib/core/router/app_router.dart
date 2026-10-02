import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/tracking/presentation/pages/activity_page.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_page.dart';
import '../../features/tracking/presentation/pages/activity_summary_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/social/presentation/pages/comments_page.dart';
import '../../features/social/presentation/pages/search_page.dart';
import '../../features/social/presentation/pages/create_post_page.dart';
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorActivityKey = GlobalKey<NavigatorState>(debugLabel: 'shellActivity');
final _shellNavigatorLeaderboardKey = GlobalKey<NavigatorState>(debugLabel: 'shellLeaderboard');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      // The Splash screen handles the initial routing logic.
      // We only restrict logged-out users from entering main app flows.
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' || 
                          state.matchedLocation == '/splash';

      if (!isAuthenticated && !isAuthRoute) {
        return '/splash';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorActivityKey,
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) => const ActivityPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLeaderboardKey,
            routes: [
              GoRoute(
                path: '/leaderboard',
                builder: (context, state) => const LeaderboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/activity-summary',
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is Map<String, dynamic> ? extra : <String, dynamic>{};
          return ActivitySummaryPage(
            duration: args['duration'] as Duration? ?? Duration.zero,
            distanceKm: (args['distanceKm'] as num?)?.toDouble() ?? 0.0,
            routeCoordinates: (args['routeCoordinates'] as List?)?.cast() ?? [],
            gpsPointCount: (args['gpsPointCount'] as int?) ?? 0,
            capturedCellsCount: (args['capturedCellsCount'] as int?) ?? 0,
            capturedCells: (args['capturedCells'] as List?)?.cast() ?? [],
            territoryAreaSqKm: (args['territoryAreaSqKm'] as num?)?.toDouble() ?? 0.0,
            isLoopCompleted: (args['isLoopCompleted'] as bool?) ?? false,
            earnedPoints: (args['earnedPoints'] as int?) ?? 0,
            averageSpeedKmh: (args['averageSpeedKmh'] as num?)?.toDouble() ?? 0.0,
            estimatedCalories: (args['estimatedCalories'] as num?)?.toDouble() ?? 0.0,
          );
        },
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is Map<String, dynamic> ? extra : <String, dynamic>{};
          return CreatePostPage(
            duration: args['duration'] as Duration?,
            distanceKm: (args['distanceKm'] as num?)?.toDouble(),
            routeCoordinates: (args['routeCoordinates'] as List?)?.cast(),
            gpsPointCount: args['gpsPointCount'] as int?,
            capturedCellsCount: args['capturedCellsCount'] as int?,
            territoryAreaSqKm: (args['territoryAreaSqKm'] as num?)?.toDouble(),
            isLoopCompleted: args['isLoopCompleted'] as bool?,
            earnedPoints: args['earnedPoints'] as int?,
            averageSpeedKmh: (args['averageSpeedKmh'] as num?)?.toDouble(),
            estimatedCalories: (args['estimatedCalories'] as num?)?.toDouble(),
          );
        },
      ),
      GoRoute(
        path: '/comments/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return CommentsPage(postId: postId);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/public-profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return PublicProfilePage(userId: userId);
        },
      ),
    ],
  );
});
