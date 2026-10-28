import 'package:go_router/go_router.dart';
import 'package:syaahi_app/features/splash/splash_screen.dart';
import 'package:syaahi_app/features/welcome/welcome_screen.dart';
import 'package:syaahi_app/features/auth/presentation/signup_screen.dart';
import 'package:syaahi_app/features/auth/presentation/login_screen.dart';
import 'package:syaahi_app/features/poems/presentation/feed_screen.dart';
import 'package:syaahi_app/features/poems/presentation/reader_screen.dart';
import 'package:syaahi_app/features/poems/presentation/writer_screen.dart';
import 'package:syaahi_app/features/poems/presentation/heart_screen.dart';
import 'package:syaahi_app/features/profile/profile_screen.dart';
import 'package:syaahi_app/features/notifications/presentation/inbox_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
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
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const InboxScreen(),
      ),
    ],
  );
}
