import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syaahi_app/core/constants/colors.dart';
import 'package:syaahi_app/core/constants/sizes.dart';
import 'package:syaahi_app/features/splash/splash_screen.dart';
import 'package:syaahi_app/features/welcome/welcome_screen.dart';
import 'package:syaahi_app/features/auth/presentation/signup_screen.dart';
import 'package:syaahi_app/features/auth/presentation/login_screen.dart';
import 'package:syaahi_app/features/poems/presentation/feed_screen.dart';
import 'package:syaahi_app/features/poems/presentation/reader_screen.dart';
import 'package:syaahi_app/features/poems/presentation/writer_screen.dart';
import 'package:syaahi_app/features/poems/presentation/heart_screen.dart';
import 'package:syaahi_app/features/profile/profile_screen.dart';
import 'package:syaahi_app/features/profile/presentation/author_profile_screen.dart';
import 'package:syaahi_app/features/notifications/presentation/inbox_screen.dart';
import 'package:syaahi_app/features/auth/state/auth_providers.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    redirect: _redirect,
    errorBuilder: (context, state) => _NotFoundScreen(path: state.uri.path),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/write',
        builder: (context, state) => const WriterScreen(),
      ),
      GoRoute(
        path: '/poem/:id',
        builder: (context, state) =>
            ReaderScreen(poemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/heart',
        builder: (context, state) => const HeartScreen(),
      ),
      // Own profile — reads authProvider, delegates to AuthorProfileView
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Public author profile — fetches by username
      GoRoute(
        path: '/profile/:username',
        builder: (context, state) => AuthorProfileScreen(
          username: state.pathParameters['username']!,
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const InboxScreen(),
      ),
    ],
  );

  // ── Auth Guard ──────────────────────────────────────────────────
  static String? _redirect(BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isLoggedIn = container.read(authProvider).user != null;
    final path = state.matchedLocation;

    // Classify the destination
    final isSplash = path == '/';
    final isWelcome = path == '/welcome';
    final isAuth = path.startsWith('/auth/');
    final isPoem = path.startsWith('/poem/');
    // /profile/:username is public; exact /profile is protected
    final isPublicProfile =
        path.startsWith('/profile/') && path.length > '/profile/'.length;

    final isPublic =
        isSplash || isWelcome || isAuth || isPoem || isPublicProfile;

    // Protected routes: /home, /write, /heart, /profile, /notifications
    final isProtected = !isPublic;

    // Unauthenticated user trying to reach a protected route
    if (!isLoggedIn && isProtected) {
      return '/welcome';
    }

    // Authenticated user trying to reach auth/welcome screens
    if (isLoggedIn && (isWelcome || isAuth)) {
      return '/home';
    }

    return null; // No redirect
  }
}

// ── Branded 404 Screen ────────────────────────────────────────────
class _NotFoundScreen extends StatelessWidget {
  final String path;
  const _NotFoundScreen({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SyaahiColors.midnightDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Not Found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SyaahiSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.explore_off_outlined,
                size: 64,
                color: SyaahiColors.textFaded,
              ),
              const SizedBox(height: SyaahiSizes.lg),
              Text(
                'This page doesn\'t exist.',
                style: GoogleFonts.cormorantGaramond(
                  color: SyaahiColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SyaahiSizes.sm),
              Text(
                path,
                style: GoogleFonts.inter(
                  color: SyaahiColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: SyaahiSizes.xl),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go to Feed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
