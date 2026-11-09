import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../auth/state/auth_providers.dart';
import '../data/resonance_repository.dart';
import '../state/resonance_providers.dart';

class ResponseItem extends ConsumerStatefulWidget {
  final String poemId;
  final String authorId;
  final ResonanceResponseModel response;

  const ResponseItem({
    super.key,
    required this.poemId,
    required this.authorId,
    required this.response,
  });

  @override
  ConsumerState<ResponseItem> createState() => _ResponseItemState();
}

class _ResponseItemState extends ConsumerState<ResponseItem> {
  bool _isEditingResponse = false;
  final _editResponseController = TextEditingController();

  bool _isReplying = false;
  final _replyController = TextEditingController();
  int _replyCharCount = 0;

  bool _isEditingReply = false;
  final _editReplyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() {
      if (mounted) {
        setState(() {
          _replyCharCount = _replyController.text.trim().length;
        });
      }
    });
  }

  @override
  void dispose() {
    _editResponseController.dispose();
    _replyController.dispose();
    _editReplyController.dispose();
    super.dispose();
  }

  void _startEditingResponse() {
    _editResponseController.text = widget.response.content;
    setState(() {
      _isEditingResponse = true;
    });
  }

  Future<void> _saveResponseEdit() async {
    final text = _editResponseController.text.trim();
    if (text.isEmpty || text.length > 280) return;

    final success = await ref
        .read(resonanceProvider(widget.poemId).notifier)
        .editResponse(widget.response.id, text);

    if (success && mounted) {
      setState(() {
        _isEditingResponse = false;
      });
    }
  }

  Future<void> _deleteResponse() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyaahiColors.midnightBase,
        title: Text(
          'Delete response?',
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently remove your response and any author reply.',
          style: GoogleFonts.inter(
            color: SyaahiColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: SyaahiColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
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
      await ref
          .read(resonanceProvider(widget.poemId).notifier)
          .deleteResponse(widget.response.id);
    }
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || text.length > 280) return;

    final success = await ref
        .read(resonanceProvider(widget.poemId).notifier)
        .submitReply(widget.response.id, text);

    if (success && mounted) {
      _replyController.clear();
      setState(() {
        _isReplying = false;
        _replyCharCount = 0;
      });
    } else if (mounted) {
      final err = ref.read(resonanceProvider(widget.poemId)).actionError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err ?? 'Failed to post reply. Please try again.',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: SyaahiColors.error,
        ),
      );
    }
  }

  Future<void> _saveReplyEdit() async {
    if (widget.response.reply == null) return;
    final text = _editReplyController.text.trim();
    if (text.isEmpty || text.length > 280) return;

    final success = await ref
        .read(resonanceProvider(widget.poemId).notifier)
        .editReply(
          widget.response.id,
          widget.response.reply!.id,
          text,
        );

    if (success && mounted) {
      setState(() {
        _isEditingReply = false;
      });
    }
  }

  Future<void> _deleteReply() async {
    if (widget.response.reply == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SyaahiColors.midnightBase,
        title: Text(
          'Delete reply?',
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently remove your author reply.',
          style: GoogleFonts.inter(
            color: SyaahiColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: SyaahiColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
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
      await ref
          .read(resonanceProvider(widget.poemId).notifier)
          .deleteReply(
            widget.response.id,
            widget.response.reply!.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final isOwnResponse = currentUser?.id == widget.response.userId;
    final isPoemAuthor = currentUser?.id == widget.authorId;
    final reply = widget.response.reply;

    return Container(
      margin: const EdgeInsets.only(bottom: SyaahiSizes.md),
      padding: const EdgeInsets.all(SyaahiSizes.md),
      decoration: BoxDecoration(
        color: SyaahiColors.surfaceCard,
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusLg),
        border: Border.all(
          color: SyaahiColors.divider,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, timestamp, actions
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: SyaahiColors.midnightLight,
                backgroundImage: widget.response.user.avatarUrl != null
                    ? NetworkImage(widget.response.user.avatarUrl!)
                    : null,
                child: widget.response.user.avatarUrl == null
                    ? Text(
                        widget.response.user.displayName.isNotEmpty
                            ? widget.response.user.displayName[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: SyaahiColors.goldBase,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: SyaahiSizes.sm),
              Expanded(
                child: Text(
                  widget.response.user.displayName,
                  style: GoogleFonts.inter(
                    color: SyaahiColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOwnResponse && !_isEditingResponse) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  color: SyaahiColors.textFaded,
                  onPressed: _startEditingResponse,
                  tooltip: 'Edit Response',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  color: SyaahiColors.textFaded,
                  onPressed: _deleteResponse,
                  tooltip: 'Delete Response',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ],
          ),
          const SizedBox(height: SyaahiSizes.sm),

          // Response Body or Edit Mode
          if (_isEditingResponse) ...[
            TextField(
              controller: _editResponseController,
              maxLength: 280,
              maxLines: 3,
              style: GoogleFonts.inter(
                color: SyaahiColors.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: SyaahiSizes.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditingResponse = false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: SyaahiColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveResponseEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SyaahiColors.goldBase,
                    foregroundColor: SyaahiColors.midnightDark,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ] else ...[
            SelectableText(
              widget.response.content,
              style: GoogleFonts.cormorantGaramond(
                color: SyaahiColors.textSecondary,
                fontSize: 16,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Author Reply Display
          if (reply != null) ...[
            const SizedBox(height: SyaahiSizes.md),
            Container(
              padding: const EdgeInsets.all(SyaahiSizes.md),
              decoration: BoxDecoration(
                color: SyaahiColors.goldBase.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
                border: Border(
                  left: BorderSide(
                    color: SyaahiColors.goldBase,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_edu_outlined,
                        size: 14,
                        color: SyaahiColors.goldBase,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Author Reply',
                        style: GoogleFonts.inter(
                          color: SyaahiColors.goldBase,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      if (isPoemAuthor && !_isEditingReply) ...[
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 14),
                          color: SyaahiColors.textFaded,
                          onPressed: () {
                            _editReplyController.text = reply.content;
                            setState(() => _isEditingReply = true);
                          },
                          tooltip: 'Edit Reply',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(2),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 14),
                          color: SyaahiColors.textFaded,
                          onPressed: _deleteReply,
                          tooltip: 'Delete Reply',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: SyaahiSizes.xs),
                  if (_isEditingReply) ...[
                    TextField(
                      controller: _editReplyController,
                      maxLength: 280,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        color: SyaahiColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              setState(() => _isEditingReply = false),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: SyaahiColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _saveReplyEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SyaahiColors.goldBase,
                            foregroundColor: SyaahiColors.midnightDark,
                          ),
                          child: const Text('Save Reply'),
                        ),
                      ],
                    ),
                  ] else ...[
                    SelectableText(
                      reply.content,
                      style: GoogleFonts.inter(
                        color: SyaahiColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Author Reply Composer Container
          if (isPoemAuthor && reply == null) ...[
            const SizedBox(height: SyaahiSizes.sm),
            if (!_isReplying)
              TextButton.icon(
                onPressed: () => setState(() => _isReplying = true),
                icon: const Icon(Icons.reply, size: 14),
                label: const Text('Acknowledge / Reply as Author'),
                style: TextButton.styleFrom(
                  foregroundColor: SyaahiColors.goldBase,
                  textStyle: GoogleFonts.inter(fontSize: 12),
                  padding: EdgeInsets.zero,
                ),
              )
            else ...[
              const SizedBox(height: SyaahiSizes.xs),
              Container(
                padding: const EdgeInsets.all(SyaahiSizes.sm),
                decoration: BoxDecoration(
                  color: SyaahiColors.midnightLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
                  border: Border.all(
                    color: SyaahiColors.divider,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _replyController,
                      maxLength: 280,
                      maxLines: 3,
                      minLines: 2,
                      style: GoogleFonts.inter(
                        color: SyaahiColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write a thoughtful reply...',
                        hintStyle: GoogleFonts.inter(
                          color: SyaahiColors.textFaded,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: SyaahiSizes.xs),
                    Row(
                      children: [
                        Text(
                          '$_replyCharCount / 280',
                          style: GoogleFonts.inter(
                            color: _replyCharCount > 280
                                ? SyaahiColors.error
                                : SyaahiColors.textFaded,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() {
                            _isReplying = false;
                            _replyController.clear();
                            _replyCharCount = 0;
                          }),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SyaahiSizes.sm,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              color: SyaahiColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: SyaahiSizes.xs),
                        Consumer(
                          builder: (context, ref, child) {
                            final rState = ref.watch(
                              resonanceProvider(widget.poemId),
                            );
                            final canSubmit = _replyCharCount > 0 &&
                                _replyCharCount <= 280 &&
                                !rState.isSubmitting;
                            return ElevatedButton(
                              onPressed: canSubmit ? _submitReply : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                backgroundColor: SyaahiColors.goldBase,
                                foregroundColor: SyaahiColors.midnightDark,
                                disabledBackgroundColor: SyaahiColors.goldBase
                                    .withValues(alpha: 0.3),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SyaahiSizes.md,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    SyaahiSizes.radiusFull,
                                  ),
                                ),
                              ),
                              child: rState.isSubmitting
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: SyaahiColors.midnightDark,
                                      ),
                                    )
                                  : Text(
                                      'Post Reply',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
