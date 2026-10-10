import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../features/auth/auth_page.dart';
import '../features/auth/register_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/game/game_page.dart';
import '../features/game/result_page.dart';
import '../features/home/home_page.dart';
import '../features/levels/levels_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/parent_dashboard_page.dart';
import '../features/rewards/rewards_page.dart';
import '../features/settings/app_info_page.dart';
import '../features/settings/privacy_policy_page.dart';
import '../features/settings/settings_page.dart';
import '../features/splash/splash_page.dart';
import '../features/worlds/worlds_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const AuthPage()),
      ),
      GoRoute(
        path: AppRoutes.authLogin,
        pageBuilder: (context, state) => _buildCinematicPage(
          state,
          const AuthPage(showLoginInitially: true),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const RegisterPage()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const HomePage()),
      ),
      GoRoute(
        path: AppRoutes.worlds,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const WorldsPage()),
      ),
      GoRoute(
        path: AppRoutes.levels,
        pageBuilder: (context, state) {
          final worldId = state.uri.queryParameters['world'] ?? 'forest_rescue';
          return _buildCinematicPage(state, LevelsPage(worldId: worldId));
        },
      ),
      GoRoute(
        path: AppRoutes.game,
        pageBuilder: (context, state) {
          final level =
              int.tryParse(state.uri.queryParameters['level'] ?? '1') ?? 1;
          final worldId = state.uri.queryParameters['world'] ?? 'forest_rescue';
          final dbLevelId =
              int.tryParse(state.uri.queryParameters['dbLevelId'] ?? '');
          return _buildCinematicPage(
            state,
            GamePage(levelNumber: level, worldId: worldId, dbLevelId: dbLevelId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.result,
        pageBuilder: (context, state) {
          final score =
              int.tryParse(state.uri.queryParameters['score'] ?? '0') ?? 0;
          final stars =
              int.tryParse(state.uri.queryParameters['stars'] ?? '0') ?? 0;
          final worldId = state.uri.queryParameters['world'] ?? 'forest_rescue';
          final level =
              int.tryParse(state.uri.queryParameters['level'] ?? '1') ?? 1;
          final dbLevelId =
              int.tryParse(state.uri.queryParameters['dbLevelId'] ?? '');
          return _buildCinematicPage(
            state,
            ResultPage(
              score: score,
              stars: stars,
              worldId: worldId,
              levelNumber: level,
              dbLevelId: dbLevelId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.rewards,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const RewardsPage()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const ProfilePage()),
      ),
      GoRoute(
        path: AppRoutes.parentDashboard,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const ParentDashboardPage()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const SettingsPage()),
      ),
      GoRoute(
        path: AppRoutes.appInfo,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const AppInfoPage()),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        pageBuilder: (context, state) =>
            _buildCinematicPage(state, const PrivacyPolicyPage()),
      ),
    ],
  );
});

CustomTransitionPage<void> _buildCinematicPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
