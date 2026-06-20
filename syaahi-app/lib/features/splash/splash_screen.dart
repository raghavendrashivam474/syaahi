import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';
import '../../core/storage/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    // Wait for splash animation to be visible
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Session recovery: if a token exists, go straight to home
    final token = await _tokenStorage.getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      context.go('/home');
    } else {
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              SyaahiColors.midnightBase,
              SyaahiColors.midnightDark,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    size: 80,
                    color: SyaahiColors.goldBase,
                  ),
                  const SizedBox(height: SyaahiSizes.lg),
                  Text(
                    SyaahiStrings.appName,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      color: SyaahiColors.goldBase,
                      letterSpacing: 2.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: SyaahiSizes.md),
                  Container(
                    width: 60,
                    height: 1,
                    color: SyaahiColors.goldDark.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: SyaahiSizes.md),
                  Text(
                    SyaahiStrings.tagline,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: SyaahiColors.textMuted,
                      letterSpacing: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}