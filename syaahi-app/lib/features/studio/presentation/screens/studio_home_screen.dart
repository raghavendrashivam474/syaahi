import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/sizes.dart';
import '../../domain/models/draft_poem.dart';
import '../../state/studio_providers.dart';

class StudioHomeScreen extends ConsumerWidget {
  const StudioHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studioProvider);
    final notifier = ref.read(studioProvider.notifier);

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
          'Syaahi Studio',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: SyaahiColors.goldBase,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: SyaahiColors.textMuted),
            onPressed: () => notifier.loadDrafts(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: SyaahiColors.goldBase))
          : state.drafts.isEmpty
              ? _EmptyDraftsView(onNewDraft: () {
                  notifier.createNewDraft();
                  context.push('/studio/editor');
                })
              : RefreshIndicator(
                  color: SyaahiColors.goldBase,
                  onRefresh: () => notifier.loadDrafts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(SyaahiSizes.md),
                    itemCount: state.drafts.length,
                    itemBuilder: (context, index) {
                      final draft = state.drafts[index];
                      return _DraftCard(
                        draft: draft,
                        onTap: () {
                          notifier.selectDraft(draft);
                          context.push('/studio/editor');
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: SyaahiColors.midnightBase,
                              title: const Text('Delete Draft?', style: TextStyle(color: SyaahiColors.textPrimary)),
                              content: const Text('This action cannot be undone.', style: TextStyle(color: SyaahiColors.textMuted)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete', style: TextStyle(color: SyaahiColors.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            notifier.deleteDraft(draft.id);
                          }
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SyaahiColors.goldBase,
        foregroundColor: SyaahiColors.midnightDark,
        icon: const Icon(Icons.edit_note),
        label: Text('New Draft', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        onPressed: () {
          notifier.createNewDraft();
          context.push('/studio/editor');
        },
      ),
    );
  }
}

class _EmptyDraftsView extends StatelessWidget {
  final VoidCallback onNewDraft;
  const _EmptyDraftsView({required this.onNewDraft});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SyaahiSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_edu, size: 64, color: SyaahiColors.textFaded),
            const SizedBox(height: SyaahiSizes.lg),
            Text(
              'Your Studio is Quiet',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: SyaahiColors.textPrimary,
              ),
            ),
            const SizedBox(height: SyaahiSizes.xs),
            Text(
              'Capture your thoughts and draft your verses without network dependency.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: SyaahiColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: SyaahiSizes.xl),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SyaahiColors.goldBase,
                foregroundColor: SyaahiColors.midnightDark,
                padding: const EdgeInsets.symmetric(horizontal: SyaahiSizes.lg, vertical: SyaahiSizes.md),
              ),
              onPressed: onNewDraft,
              icon: const Icon(Icons.add),
              label: const Text('Create First Draft'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final DraftPoem draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = draft.title?.isNotEmpty == true ? draft.title! : 'Untitled Draft';
    final preview = draft.content.isNotEmpty ? draft.content : 'Empty draft...';
    final formattedDate = DateFormat('MMM d, h:mm a').format(draft.updatedAt);

    return Card(
      color: SyaahiColors.midnightBase,
      margin: const EdgeInsets.only(bottom: SyaahiSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
        side: const BorderSide(color: SyaahiColors.divider, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(SyaahiSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SyaahiColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _SyncBadge(status: draft.syncStatus),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: SyaahiColors.textMuted),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: SyaahiSizes.xs),
              Text(
                preview,
                style: GoogleFonts.inter(color: SyaahiColors.textMuted, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SyaahiSizes.sm),
              Row(
                children: [
                  Text(
                    draft.language.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: SyaahiColors.goldBase,
                    ),
                  ),
                  const SizedBox(width: SyaahiSizes.sm),
                  Text(
                    formattedDate,
                    style: GoogleFonts.inter(fontSize: 11, color: SyaahiColors.textFaded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final SyncStatus status;
  const _SyncBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      SyncStatus.synced => (SyaahiColors.goldBase, Icons.cloud_done),
      SyncStatus.pendingSync => (SyaahiColors.goldLight, Icons.cloud_upload),
      SyncStatus.syncFailed => (SyaahiColors.error, Icons.cloud_off),
      SyncStatus.localOnly => (SyaahiColors.textFaded, Icons.smartphone),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}


