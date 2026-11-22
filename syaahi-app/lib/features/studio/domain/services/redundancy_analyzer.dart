import '../models/writing_intelligence_models.dart';

/// Rule-based redundant expression dictionary entry.
class RedundancyPattern {
  final RegExp regex;
  final String description;
  final String suggestedAlternative;

  RedundancyPattern({
    required String pattern,
    required this.description,
    required this.suggestedAlternative,
    bool caseSensitive = false,
  }) : regex = RegExp(pattern, caseSensitive: caseSensitive);
}

/// Analyzes text for verbal redundancies, tautologies, and redundant line phrasing.
class RedundancyAnalyzer {
  /// Well-curated list of common redundant phrases.
  static final List<RedundancyPattern> commonRedundancies = [
    RedundancyPattern(
      pattern: r'\breturned?\s+back\b',
      description: '"Returned" already implies returning to a previous state.',
      suggestedAlternative: 'returned',
    ),
    RedundancyPattern(
      pattern: r'\breason\s+is\s+because\b',
      description: '"Reason" and "because" express the same causal relationship.',
      suggestedAlternative: 'reason is that',
    ),
    RedundancyPattern(
      pattern: r'\bclose\s+proximity\b',
      description: '"Proximity" means closeness.',
      suggestedAlternative: 'proximity',
    ),
    RedundancyPattern(
      pattern: r'\bend\s+result\b',
      description: 'A result is already the end outcome.',
      suggestedAlternative: 'result',
    ),
    RedundancyPattern(
      pattern: r'\bfree\s+gift\b',
      description: 'A gift is inherently free.',
      suggestedAlternative: 'gift',
    ),
    RedundancyPattern(
      pattern: r'\bpast\s+history\b',
      description: 'History is always in the past.',
      suggestedAlternative: 'history',
    ),
    RedundancyPattern(
      pattern: r'\bfuture\s+plans?\b',
      description: 'Plans inherently concern the future.',
      suggestedAlternative: 'plans',
    ),
    RedundancyPattern(
      pattern: r'\bunexpected\s+surprise\b',
      description: 'Surprises are by nature unexpected.',
      suggestedAlternative: 'surprise',
    ),
    RedundancyPattern(
      pattern: r'\bblending\s+together\b',
      description: '"Together" is implicit in blending.',
      suggestedAlternative: 'blending',
    ),
    RedundancyPattern(
      pattern: r'\brepeat(?:\s+that)?\s+again\b',
      description: '"Repeat" already means to perform or say again.',
      suggestedAlternative: 'repeat',
    ),
    RedundancyPattern(
      pattern: r'\bjoin\s+together\b',
      description: '"Join" implies coming together.',
      suggestedAlternative: 'join',
    ),
    RedundancyPattern(
      pattern: r'\bshout(?:ed)?\s+out\s+loud\b',
      description: 'Shouting is inherently loud.',
      suggestedAlternative: 'shouted',
    ),
  ];

  /// Main redundancy detection entry point.
  static List<WritingSuggestion> analyze(String text) {
    if (text.trim().isEmpty) return const [];

    final suggestions = <WritingSuggestion>[];

    // 1. Pattern-based redundancy detection
    for (final rule in commonRedundancies) {
      for (final match in rule.regex.allMatches(text)) {
        final original = text.substring(match.start, match.end);

        suggestions.add(WritingSuggestion(
          id: 'redundancy_pattern_${match.start}',
          type: WritingIssueType.redundancy,
          originalText: original,
          explanation: rule.description,
          startOffset: match.start,
          endOffset: match.end,
          alternatives: [rule.suggestedAlternative],
          contextSnippet: _extractSnippet(text, match.start, match.end),
        ));
      }
    }

    // 2. Line-level similarity redundancy detection (consecutive duplicate/near-duplicate lines)
    suggestions.addAll(_detectRedundantLines(text));

    return suggestions;
  }

  /// Detects consecutive lines that share >= 65% Jaccard word similarity.
  static List<WritingSuggestion> _detectRedundantLines(String text) {
    final suggestions = <WritingSuggestion>[];
    final lines = text.split('\n');

    var currentOffset = 0;
    final lineOffsets = <LineInfo>[];

    for (final line in lines) {
      final start = currentOffset;
      final end = start + line.length;
      lineOffsets.add(LineInfo(text: line, start: start, end: end));
      currentOffset = end + 1; // account for newline
    }

    for (var i = 0; i < lineOffsets.length - 1; i++) {
      final l1 = lineOffsets[i];
      final l2 = lineOffsets[i + 1];

      final t1 = l1.text.trim();
      final t2 = l2.text.trim();

      if (t1.isEmpty || t2.isEmpty) continue;
      if (t1.length < 10 || t2.length < 10) continue;

      final similarity = _calculateJaccardSimilarity(t1, t2);

      if (similarity >= 0.65) {
        suggestions.add(WritingSuggestion(
          id: 'redundancy_line_${l2.start}',
          type: WritingIssueType.redundancy,
          originalText: l2.text,
          explanation:
              'This line expresses nearly identical content to the preceding line ("${_truncate(t1, 30)}"). Consider merging or revising.',
          startOffset: l2.start,
          endOffset: l2.end,
          contextSnippet: '${l1.text}\n${l2.text}',
        ));
      }
    }

    return suggestions;
  }

  static double _calculateJaccardSimilarity(String s1, String s2) {
    final words1 = RegExp(r'\w+').allMatches(s1.toLowerCase()).map((m) => m.group(0)!).toSet();
    final words2 = RegExp(r'\w+').allMatches(s2.toLowerCase()).map((m) => m.group(0)!).toSet();

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;

    return intersection / union;
  }

  static String _extractSnippet(String text, int start, int end) {
    const margin = 15;
    final snippetStart = (start - margin) < 0 ? 0 : start - margin;
    final snippetEnd = (end + margin) > text.length ? text.length : end + margin;

    var snippet = text.substring(snippetStart, snippetEnd).replaceAll('\n', ' ');
    if (snippetStart > 0) snippet = '...$snippet';
    if (snippetEnd < text.length) snippet = '$snippet...';
    return snippet;
  }

  static String _truncate(String str, int maxLen) {
    if (str.length <= maxLen) return str;
    return '${str.substring(0, maxLen)}...';
  }
}

class LineInfo {
  final String text;
  final int start;
  final int end;

  LineInfo({required this.text, required this.start, required this.end});
}
