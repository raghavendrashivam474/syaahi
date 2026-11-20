import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../../../shared/models/poem.dart';
import '../../state/studio_providers.dart';

class StudioEditorScreen extends ConsumerStatefulWidget {
  const StudioEditorScreen({super.key});

  @override
  ConsumerState<StudioEditorScreen> createState() => _StudioEditorScreenState();
}

class _StudioEditorScreenState extends ConsumerState<StudioEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.override;
    final current = ref.read(studioProvider).currentDraft;
    _titleController = TextEditingController(text: current?.title ?? '');
    _contentController = TextEditingController(text: current?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studioProvider);
    final notifier = ref.read(studioProvider.notifier);
    final draft = state.currentDraft;

    return Scaffold(
      backgroundColor: SyaahiColors.midnightDark,
      appBar: AppBar(
        backgroundColor: SyaahiColors.midnightBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SyaahiColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          state.saveStatus.label,
          style: GoogleFonts.inter(fontSize: 12, color: SyaahiColors.goldBase),
        ),
        actions: [
          if (state.isPublishing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: SyaahiColors.goldBase),
              ),
            )
          else
            TextButton.icon(
              onPressed: () async {
                final poem = await notifier.publishCurrentDraft();
                if (poem != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Poem published successfully!')),
                  );
                  context.pushReplacement('/poem/${poem.id}');
                }
              },
              icon: const Icon(Icons.publish, size: 18, color: SyaahiColors.goldBase),
              label: Text(
                'Publish',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: SyaahiColors.goldBase),
              ),
            ),
        ],
      ),
      body: draft == null
          ? const Center(child: Text('No active draft', style: TextStyle(color: SyaahiColors.textMuted)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SyaahiSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(SyaahiSizes.sm),
                        decoration: BoxDecoration(
                          color: SyaahiColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(SyaahiSizes.radiusSm),
                        ),
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: SyaahiColors.errorRed, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: SyaahiSizes.md),
                    ],

                    // Language Selector
                    Row(
                      children: [
                        Text('Language: ', style: GoogleFonts.inter(color: SyaahiColors.textMuted, fontSize: 12)),
                        DropdownButton<PoemLanguage>(
                          value: draft.language,
                          dropdownColor: SyaahiColors.midnightBase,
                          style: const TextStyle(color: SyaahiColors.goldBase, fontSize: 12),
                          underline: const SizedBox(),
                          items: PoemLanguage.values
                              .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
                              .toList(),
                          onChanged: (lang) {
                            if (lang != null) notifier.updateLanguage(lang);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: SyaahiSizes.sm),

                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: SyaahiColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title (optional)',
                        hintStyle: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          color: SyaahiColors.textFaded,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => notifier.updateTitle(val),
                    ),

                    const Divider(color: SyaahiColors.divider, height: 1),
                    const SizedBox(height: SyaahiSizes.md),

                    // Main Content Canvas
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        height: 1.6,
                        color: SyaahiColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write your poem here...',
                        hintStyle: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          color: SyaahiColors.textFaded,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => notifier.updateContent(val),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
