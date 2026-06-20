import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../state/auth_providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _displayNameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).signup(
          email: _emailCtrl.text.trim(),
          username: _usernameCtrl.text.trim().toLowerCase(),
          displayName: _displayNameCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: SyaahiSizes.xl,
            vertical: SyaahiSizes.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: SyaahiSizes.md),
                Text(
                  'Begin Your Journey',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36,
                    color: SyaahiColors.goldBase,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SyaahiSizes.sm),
                Text(
                  'Create your sanctuary for words.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: SyaahiSizes.xl),

                TextFormField(
                  controller: _displayNameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'How others will see you',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Display name is required'
                      : null,
                ),
                const SizedBox(height: SyaahiSizes.md),

                TextFormField(
                  controller: _usernameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'lowercase, no spaces (e.g., kavya)',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username is required';
                    if (v.length < 3) return 'Min 3 characters';
                    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v)) {
                      return 'lowercase, numbers, underscore only';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: SyaahiSizes.md),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: SyaahiSizes.md),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'At least 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Min 8 characters';
                    return null;
                  },
                ),

                if (state.error != null) ...[
                  const SizedBox(height: SyaahiSizes.md),
                  Container(
                    padding: const EdgeInsets.all(SyaahiSizes.md),
                    decoration: BoxDecoration(
                      color: SyaahiColors.error.withValues(alpha: 0.1),
                      border: Border.all(color: SyaahiColors.error.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: SyaahiColors.error, size: 20),
                        const SizedBox(width: SyaahiSizes.sm),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: GoogleFonts.inter(color: SyaahiColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: SyaahiSizes.xl),

                ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SyaahiColors.midnightDark,
                          ),
                        )
                      : const Text('Create Account'),
                ),
                const SizedBox(height: SyaahiSizes.md),

                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: SyaahiColors.textMuted,
                      ),
                      children: const [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: SyaahiColors.goldLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}