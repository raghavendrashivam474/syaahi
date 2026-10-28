import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/sizes.dart';
import '../data/notifications_repository.dart';
import '../state/notifications_providers.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(inboxProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inboxProvider);
    final hasUnread = state.items.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: SyaahiColors.midnightDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SyaahiColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: state.isMarkingAllRead
                  ? null
                  : () => ref.read(inboxProvider.notifier).markAllAsRead(),
              child: state.isMarkingAllRead
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SyaahiColors.goldBase,
                      ),
                    )
                  : Text(
                      'Read all',
                      style: GoogleFonts.inter(
                        color: SyaahiColors.goldBase,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(InboxState state) {
    // Initial loading
    if (state.isLoading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: SyaahiColors.goldBase),
      );
    }

    // Initial error
    if (state.error != null && state.items.isEmpty) {
      return _ErrorView(
        message: state.error!,
        onRetry: () => ref.read(inboxProvider.notifier).refresh(),
      );
    }

    // Empty
    if (state.items.isEmpty) {
      return _EmptyInbox();
    }

    // Loaded
    return RefreshIndicator(
      color: SyaahiColors.goldBase,
      backgroundColor: SyaahiColors.midnightBase,
      onRefresh: () => ref.read(inboxProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          SyaahiSizes.md, SyaahiSizes.sm, SyaahiSizes.md, SyaahiSizes.xxxl,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: SyaahiSizes.xs),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(SyaahiSizes.lg),
              child: Center(
                child: CircularProgressIndicator(
                  color: SyaahiColors.goldBase,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return _NotificationCard(
            notification: state.items[index],
            onTap: () => _onNotificationTap(state.items[index]),
          );
        },
      ),
    );
  }

  void _onNotificationTap(AppNotification notification) {
    // Mark as read (server-first, fire-and-forget for UX speed)
    if (!notification.isRead) {
      ref.read(inboxProvider.notifier).markAsRead(notification.id);
    }
    // Navigate to the poem using the existing reader route
    context.push('/poem/${notification.poemId}');
  }
}

// ── Notification Card ────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final poemTitle = notification.poem.title;
    final displayTitle =
        (poemTitle != null && poemTitle.isNotEmpty) ? poemTitle : 'Untitled';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SyaahiSizes.md,
          vertical: SyaahiSizes.md,
        ),
        decoration: BoxDecoration(
          color: isUnread
              ? SyaahiColors.goldBase.withValues(alpha: 0.04)
              : SyaahiColors.surfaceCard,
          borderRadius: BorderRadius.circular(SyaahiSizes.radiusMd),
          border: Border(
            left: BorderSide(
              color: isUnread
                  ? SyaahiColors.goldBase
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Padding(
              padding: const EdgeInsets.only(top: 6, right: SyaahiSizes.sm),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnread
                      ? SyaahiColors.goldBase
                      : Colors.transparent,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: GoogleFonts.cormorantGaramond(
                      color: isUnread
                          ? SyaahiColors.textPrimary
                          : SyaahiColors.textSecondary,
                      fontSize: 18,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.w400,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: SyaahiSizes.xs),
                  Text(
                    'New poem published',
                    style: GoogleFonts.inter(
                      color: SyaahiColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: SyaahiSizes.xs),
                  Text(
                    _formatTime(notification.createdAt),
                    style: GoogleFonts.inter(
                      color: SyaahiColors.textFaded,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: SyaahiColors.textFaded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('MMM d').format(createdAt);
  }
}

// ── Empty State ──────────────────────────────────────────────────────

class _EmptyInbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SyaahiSizes.xl),
      children: [
        const SizedBox(height: SyaahiSizes.xxxl),
        const Icon(
          Icons.notifications_none_outlined,
          size: 64,
          color: SyaahiColors.textFaded,
        ),
        const SizedBox(height: SyaahiSizes.lg),
        Text(
          'All quiet.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SyaahiSizes.sm),
        Text(
          'When poets you follow publish new work,\nyou will see it here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SyaahiSizes.xl),
      children: [
        const SizedBox(height: SyaahiSizes.xxxl),
        const Icon(
          Icons.cloud_off_outlined,
          size: 64,
          color: SyaahiColors.textMuted,
        ),
        const SizedBox(height: SyaahiSizes.lg),
        Text(
          'Could not load notifications',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            color: SyaahiColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SyaahiSizes.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: SyaahiColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: SyaahiSizes.lg),
        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
