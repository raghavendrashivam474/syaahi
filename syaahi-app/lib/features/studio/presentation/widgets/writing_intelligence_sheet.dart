import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/writing_intelligence_models.dart';
import '../../state/writing_intelligence_providers.dart';

/// Modal bottom sheet presenting Writing Intelligence feedback and actions.
class WritingIntelligenceSheet extends ConsumerWidget {
  final String currentText;
  final Function(int startOffset, int endOffset, String replacement) onApplyReplacement;

  const WritingIntelligenceSheet({
    super.key,
    required this.currentText,
    required this.onApplyReplacement,
  });

  /// Displays the Writing Intelligence Sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required String currentText,
    required Function(int startOffset, int endOffset, String replacement) onApplyReplacement,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WritingIntelligenceSheet(
        currentText: currentText,
        onApplyReplacement: onApplyReplacement,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingIntelligenceProvider);
    final notifier = ref.read(writingIntelligenceProvider.notifier);
    final theme = Theme.of(context);

    final activeSuggestions = state.activeSuggestions;
    final tabSuggestions = state.activeTabSuggestions;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Writing Intelligence',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close Intelligence',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Overview Metrics Bar
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricTile(
                  label: 'Total Words',
                  value: '${state.analysisResult.totalWords}',
                ),
                _MetricTile(
                  label: 'Unique',
                  value: '${state.analysisResult.uniqueWords}',
                ),
                _MetricTile(
                  label: 'Richness',
                  value: '${(state.analysisResult.vocabularyRichness * 100).toInt()}%',
                ),
                _MetricTile(
                  label: 'Suggestions',
                  value: '${activeSuggestions.length}',
                  isHighlight: activeSuggestions.isNotEmpty,
                ),
              ],
            ),
          ),

          // Category Tab Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _TabChip(
                  label: 'Repeated Words (${state.analysisResult.repeatedWordCount})',
                  isSelected: state.selectedTab == WritingIssueType.repeatedWord,
                  onTap: () => notifier.selectTab(WritingIssueType.repeatedWord),
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Phrases (${state.analysisResult.repeatedPhraseCount})',
                  isSelected: state.selectedTab == WritingIssueType.repeatedPhrase,
                  onTap: () => notifier.selectTab(WritingIssueType.repeatedPhrase),
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Redundancies (${state.analysisResult.redundancyCount})',
                  isSelected: state.selectedTab == WritingIssueType.redundancy,
                  onTap: () => notifier.selectTab(WritingIssueType.redundancy),
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Suggestions (${state.analysisResult.wordSuggestionCount})',
                  isSelected: state.selectedTab == WritingIssueType.wordSuggestion,
                  onTap: () => notifier.selectTab(WritingIssueType.wordSuggestion),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Suggestion List Area
          Expanded(
            child: tabSuggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.green.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No issues identified in this category.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tabSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = tabSuggestions[index];
                      return _SuggestionCard(
                        suggestion: suggestion,
                        currentText: currentText,
                        onDismiss: () => notifier.dismissSuggestion(suggestion.id),
                        onAccept: (replacement) {
                          // Validate offsets before applying
                          if (suggestion.startOffset <= currentText.length &&
                              suggestion.endOffset <= currentText.length) {
                            onApplyReplacement(
                              suggestion.startOffset,
                              suggestion.endOffset,
                              replacement,
                            );
                            notifier.dismissSuggestion(suggestion.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Replaced with "$replacement"'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _MetricTile({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? theme.colorScheme.primary : null,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final WritingSuggestion suggestion;
  final String currentText;
  final VoidCallback onDismiss;
  final Function(String replacement) onAccept;

  const _SuggestionCard({
    required this.suggestion,
    required this.currentText,
    required this.onDismiss,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original text & dismiss button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    suggestion.originalText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Dismiss'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.textTheme.bodySmall?.color,
                  ),
                  onPressed: onDismiss,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Explanation
            Text(
              suggestion.explanation,
              style: theme.textTheme.bodyMedium,
            ),

            // Context snippet if available
            if (suggestion.contextSnippet != null) ...[
              const SizedBox(height: 6),
              Text(
                'Context: "${suggestion.contextSnippet}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],

            // Alternative chips if available
            if (suggestion.alternatives.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Tap an alternative to replace:',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: suggestion.alternatives.map((alt) {
                  return ActionChip(
                    avatar: const Icon(Icons.swap_horiz, size: 14),
                    label: Text(alt),
                    onPressed: () => onAccept(alt),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
