import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../state/resonance_providers.dart';

class ResponseComposer extends ConsumerStatefulWidget {
  final String poemId;

  const ResponseComposer({super.key, required this.poemId});

  @override
  ConsumerState<ResponseComposer> createState() => _ResponseComposerState();
}

class _ResponseComposerState extends ConsumerState<ResponseComposer> {
  final _controller = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.trim().length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > 280) return;

    final success = await ref
        .read(resonanceProvider(widget.poemId).notifier)
        .submitResponse(text);

    if (success && mounted) {
      _controller.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your resonance response has been shared.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: SyaahiColors.midnightSoft,
        ),
      );
    } else if (mounted) {
      final err = ref.read(resonanceProvider(widget.poemId)).actionError;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: SyaahiColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resonanceProvider(widget.poemId));
    final isValid = _charCount > 0 && _charCount <= 280;

    return Container(
      padding: const EdgeInsets.all(SyaahiSizes.md),
      decoration: BoxDecoration(
        color: SyaahiColors.surfaceCard,
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusLg),
        border: Border.all(color: SyaahiColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLength: 280,
            maxLines: 3,
            minLines: 2,
            style: GoogleFonts.inter(
              color: SyaahiColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'What did this poem make you feel or remember?',
              hintStyle: GoogleFonts.inter(
                color: SyaahiColors.textFaded,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              counterText: '', // We render custom char counter below
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: SyaahiSizes.sm),
          Row(
            children: [
              Text(
                '$_charCount / 280',
                style: GoogleFonts.inter(
                  color: _charCount > 280
                      ? SyaahiColors.error
                      : SyaahiColors.textFaded,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    isValid && !state.isSubmitting ? _submit : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  backgroundColor: SyaahiColors.goldBase,
                  foregroundColor: SyaahiColors.midnightDark,
                  disabledBackgroundColor:
                      SyaahiColors.goldBase.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(
                    horizontal: SyaahiSizes.lg,
                    vertical: SyaahiSizes.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SyaahiSizes.radiusFull),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SyaahiColors.midnightDark,
                        ),
                      )
                    : Text(
                        'Share Response',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
