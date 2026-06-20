import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/poems/presentation/feed_screen.dart';
import '../../features/poems/presentation/reader_screen.dart';
import '../../features/poems/presentation/writer_screen.dart';

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
    ],
  );
}