import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../../../shared/models/poem.dart';
import '../state/poems_providers.dart';
import '../../onboarding/presentation/contextual_tip.dart';

class WriterScreen extends ConsumerStatefulWidget {
  const WriterScreen({super.key});

  @override
  ConsumerState<WriterScreen> createState() => _WriterScreenState();
}

class _WriterScreenState extends ConsumerState<WriterScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _themeCtrl = TextEditingController();
  PoemLanguage _language = PoemLanguage.english;
  PoemEmotion? _emotion;

  // UX-03: Tracks whether the screen is intentionally closing
  // (e.g. after successful publish) so PopScope doesn't block it.
  bool _dismissed = false;

  bool get _hasUnsavedContent =>
      !_dismissed &&
      (_titleCtrl.text.trim().isNotEmpty ||
          _contentCtrl.text.trim().isNotEmpty ||
          _themeCtrl.text.trim().isNotEmpty);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write something first.'),
          backgroundColor: SyaahiColors.warning,
        ),
      );
      return;
    }
    final poem = await ref.read(writerProvider.notifier).publish(
          title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
          content: content,
          language: _language,
          emotion: _emotion,
          theme: _themeCtrl.text.trim().isEmpty ? null : _themeCtrl.text.trim(),
        );
    if (poem != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Published. Your words are out there. 🪶',
            style: GoogleFonts.cormorantGaramond(fontSize: 16),
          ),
          backgroundColor: SyaahiColors.success,
        ),
      );
      // UX-03: Allow pop without draft confirmation after successful publish
      _dismissed = true;
      if (mounted) context.pop();
    }
  }

  // UX-03: Draft discard confirmation
  Future<void> _confirmDiscard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyaahiColors.midnightSoft,
        title: Text(
          'Discard draft?',
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Your words will be lost. This cannot be undone.',
          style: GoogleFonts.inter(
            color: SyaahiColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Writing',
              style: GoogleFonts.inter(color: SyaahiColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Discard',
              style: GoogleFonts.inter(
                color: SyaahiColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _dismissed = true;
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(writerProvider);

    return PopScope(
      canPop: !_hasUnsavedContent,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Write'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // UX-03: Route through the same PopScope logic
              if (_hasUnsavedContent) {
                _confirmDiscard();
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: SyaahiSizes.md),
              child: TextButton(
                onPressed: state.isPublishing ? null : _publish,
                style: TextButton.styleFrom(
                  foregroundColor: SyaahiColors.goldBase,
                ),
                child: state.isPublishing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SyaahiColors.goldBase,
                        ),
                      )
                    : Text(
                        'Publish',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SyaahiSizes.xl,
              SyaahiSizes.lg,
              SyaahiSizes.xl,
              SyaahiSizes.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UX-07: First-time writing guidance
                ContextualTip(
                  feature: 'write',
                  message: 'Write freely. Add a title if you like. Tap Publish when ready.',
                  child: const SizedBox.shrink(),
                ),
                const SizedBox(height: SyaahiSizes.sm),

                // Title (optional, looks like a manuscript)
                TextField(
                  controller: _titleCtrl,
                  style: GoogleFonts.cormorantGaramond(
                    color: SyaahiColors.goldBase,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title (optional)',
                    hintStyle: GoogleFonts.cormorantGaramond(
                      color: SyaahiColors.textFaded,
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: SyaahiSizes.md),
                  height: 1,
                  color: SyaahiColors.divider,
                ),
                // Content (the canvas)
                TextField(
                  controller: _contentCtrl,
                  maxLines: null,
                  minLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.cormorantGaramond(
                    color: SyaahiColors.textPrimary,
                    fontSize: 20,
                    height: 1.7,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Let your words flow…',
                    hintStyle: GoogleFonts.cormorantGaramond(
                      color: SyaahiColors.textFaded,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: SyaahiSizes.xxl),
                Container(height: 1, color: SyaahiColors.divider),
                const SizedBox(height: SyaahiSizes.lg),
                // Emotion picker
                _SectionLabel(text: 'Emotion'),
                const SizedBox(height: SyaahiSizes.sm),
                Wrap(
                  spacing: SyaahiSizes.sm,
                  runSpacing: SyaahiSizes.sm,
                  children: PoemEmotion.values.map((e) {
                    final selected = _emotion == e;
                    return ChoiceChip(
                      label: Text('${e.emoji} ${e.label}'),
                      selected: selected,
                      onSelected: (sel) =>
                          setState(() => _emotion = sel ? e : null),
                      backgroundColor: SyaahiColors.surfaceCard,
                      selectedColor: SyaahiColors.goldBase,
                      labelStyle: GoogleFonts.inter(
                        color: selected
                            ? SyaahiColors.midnightDark
                            : SyaahiColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: selected
                            ? SyaahiColors.goldBase
                            : SyaahiColors.divider,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: SyaahiSizes.lg),
                // Language picker
                _SectionLabel(text: 'Language'),
                const SizedBox(height: SyaahiSizes.sm),
                Row(
                  children: PoemLanguage.values.map((l) {
                    final selected = _language == l;
                    return Padding(
                      padding: const EdgeInsets.only(right: SyaahiSizes.sm),
                      child: ChoiceChip(
                        label: Text(l.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _language = l),
                        backgroundColor: SyaahiColors.surfaceCard,
                        selectedColor: SyaahiColors.goldBase,
                        labelStyle: TextStyle(
                          color: selected
                              ? SyaahiColors.midnightDark
                              : SyaahiColors.textSecondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: selected
                              ? SyaahiColors.goldBase
                              : SyaahiColors.divider,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: SyaahiSizes.lg),
                // Theme (free text)
                _SectionLabel(text: 'Theme (optional)'),
                const SizedBox(height: SyaahiSizes.sm),
                TextField(
                  controller: _themeCtrl,
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g., Monsoon, Solitude, First Love',
                    prefixIcon: Icon(Icons.tag, size: 18),
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: SyaahiSizes.md),
                  Container(
                    padding: const EdgeInsets.all(SyaahiSizes.md),
                    decoration: BoxDecoration(
                      color: SyaahiColors.error.withValues(alpha: 0.1),
                      border: Border.all(
                          color: SyaahiColors.error.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: SyaahiColors.error, size: 20),
                        const SizedBox(width: SyaahiSizes.sm),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: GoogleFonts.inter(
                                color: SyaahiColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        color: SyaahiColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}

