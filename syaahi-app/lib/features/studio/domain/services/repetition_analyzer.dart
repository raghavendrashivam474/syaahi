import '../models/writing_intelligence_models.dart';

/// Analyzes text for word and phrase repetition.
class RepetitionAnalyzer {
  /// Default common stop words (English + Hindi transliterated common words).
  static const Set<String> defaultStopWords = {
    // English articles, pronouns, prepositions, conjunctions
    'a', 'an', 'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'from', 'up', 'about', 'into', 'over', 'after',
    'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had',
    'do', 'does', 'did', 'will', 'would', 'shall', 'should', 'can', 'could',
    'may', 'might', 'must', 'i', 'you', 'he', 'she', 'it', 'we', 'they',
    'me', 'him', 'her', 'us', 'them', 'my', 'your', 'his', 'its', 'our', 'their',
    'this', 'that', 'these', 'those', 'as', 'if', 'when', 'than', 'so',
    // Common Hindi transliterated stop words (duplicates removed)
    'hai', 'hain', 'ho', 'tha', 'thi', 'ka', 'ki', 'ke', 'ko',
    'se', 'par', 'main', 'tum', 'woh', 'yeh', 'kya', 'kyun', 'aur',
  };

  /// Main repetition detection entry point.
  static List<WritingSuggestion> analyze(
    String text, {
    int minWordOccurrences = 3,
    int minPhraseOccurrences = 2,
    Set<String>? stopWords,
  }) {
    if (text.trim().isEmpty) return const [];

    final activeStopWords = stopWords ?? defaultStopWords;
    final suggestions = <WritingSuggestion>[];

    // 1. Detect repeated consecutive words ("dark dark", "the the")
    suggestions.addAll(_detectConsecutiveRepeats(text));

    // 2. Detect overall word repetition beyond threshold
    suggestions.addAll(_detectWordRepetition(
      text,
      minOccurrences: minWordOccurrences,
      stopWords: activeStopWords,
    ));

    // 3. Detect repeated phrases (2 to 4 words)
    suggestions.addAll(_detectPhraseRepetition(
      text,
      minOccurrences: minPhraseOccurrences,
      stopWords: activeStopWords,
    ));

    return suggestions;
  }

  /// Detects consecutive duplicate words like "dark dark" or "the the".
  static List<WritingSuggestion> _detectConsecutiveRepeats(String text) {
    final suggestions = <WritingSuggestion>[];
    final regex = RegExp(r'\b([a-zA-Z\u0900-\u097F]+)\s+\1\b', caseSensitive: false);

    for (final match in regex.allMatches(text)) {
      final matchedText = match.group(0)!;
      final word = match.group(1)!;

      suggestions.add(WritingSuggestion(
        id: 'rep_consec_${match.start}',
        type: WritingIssueType.repeatedWord,
        originalText: matchedText,
        explanation: 'Consecutive repeated word "$word". Check if this double word is intentional.',
        startOffset: match.start,
        endOffset: match.end,
        contextSnippet: _extractSnippet(text, match.start, match.end),
      ));
    }

    return suggestions;
  }

  /// Detects non-stop words appearing [minOccurrences] or more times.
  static List<WritingSuggestion> _detectWordRepetition(
    String text, {
    required int minOccurrences,
    required Set<String> stopWords,
  }) {
    final suggestions = <WritingSuggestion>[];
    final wordRegex = RegExp(r'\b([a-zA-Z\u0900-\u097F]+)\b');
    final occurrences = <String, List<Match>>{};

    for (final match in wordRegex.allMatches(text)) {
      final rawWord = match.group(1)!;
      final normalized = rawWord.toLowerCase();

      if (normalized.length <= 2) continue; // Skip very short tokens
      if (stopWords.contains(normalized)) continue;

      occurrences.putIfAbsent(normalized, () => []).add(match);
    }

    occurrences.forEach((word, matches) {
      if (matches.length >= minOccurrences) {
        for (var i = 0; i < matches.length; i++) {
          final m = matches[i];
          final original = text.substring(m.start, m.end);

          suggestions.add(WritingSuggestion(
            id: 'rep_word_${word}_${m.start}',
            type: WritingIssueType.repeatedWord,
            originalText: original,
            explanation:
                'The word "$word" appears ${matches.length} times in your poem. Review whether all occurrences are intentional.',
            startOffset: m.start,
            endOffset: m.end,
            contextSnippet: _extractSnippet(text, m.start, m.end),
          ));
        }
      }
    });

    return suggestions;
  }

  /// Detects repeated n-grams (2 to 4 words).
  static List<WritingSuggestion> _detectPhraseRepetition(
    String text, {
    required int minOccurrences,
    required Set<String> stopWords,
  }) {
    final suggestions = <WritingSuggestion>[];
    final wordMatches = RegExp(r'\b([a-zA-Z\u0900-\u097F]+)\b').allMatches(text).toList();

    if (wordMatches.length < 4) return suggestions;

    for (var n = 2; n <= 4; n++) {
      final phraseMap = <String, List<MatchSequence>>{};

      for (var i = 0; i <= wordMatches.length - n; i++) {
        final subMatches = wordMatches.sublist(i, i + n);

        // Check if phrase contains at least one non-stop word
        final words = subMatches.map((m) => m.group(1)!.toLowerCase()).toList();
        final hasMeaningfulWord = words.any((w) => !stopWords.contains(w) && w.length > 2);
        if (!hasMeaningfulWord) continue;

        final phraseKey = words.join(' ');
        final startPos = subMatches.first.start;
        final endPos = subMatches.last.end;

        phraseMap.putIfAbsent(phraseKey, () => []).add(MatchSequence(
          start: startPos,
          end: endPos,
          rawText: text.substring(startPos, endPos),
        ));
      }

      phraseMap.forEach((phraseKey, occurrences) {
        // Filter out overlapping occurrences of the same phrase
        final nonOverlapping = _filterOverlappingSequences(occurrences);

        if (nonOverlapping.length >= minOccurrences) {
          for (final seq in nonOverlapping) {
            final id = 'rep_phrase_${phraseKey.replaceAll(" ", "_")}_${seq.start}';

            // Avoid duplicate suggestions if already registered
            if (!suggestions.any((s) => s.startOffset == seq.start && s.endOffset == seq.end)) {
              suggestions.add(WritingSuggestion(
                id: id,
                type: WritingIssueType.repeatedPhrase,
                originalText: seq.rawText,
                explanation:
                    'The phrase "${seq.rawText}" appears ${nonOverlapping.length} times in your draft.',
                startOffset: seq.start,
                endOffset: seq.end,
                contextSnippet: _extractSnippet(text, seq.start, seq.end),
              ));
            }
          }
        }
      });
    }

    return suggestions;
  }

  static List<MatchSequence> _filterOverlappingSequences(List<MatchSequence> sequences) {
    if (sequences.isEmpty) return const [];
    final result = <MatchSequence>[sequences.first];

    for (var i = 1; i < sequences.length; i++) {
      final last = result.last;
      final current = sequences[i];
      if (current.start >= last.end) {
        result.add(current);
      }
    }
    return result;
  }

  static String _extractSnippet(String text, int start, int end) {
    const margin = 20;
    final snippetStart = (start - margin) < 0 ? 0 : start - margin;
    final snippetEnd = (end + margin) > text.length ? text.length : end + margin;

    var snippet = text.substring(snippetStart, snippetEnd).replaceAll('\n', ' ');
    if (snippetStart > 0) snippet = '...$snippet';
    if (snippetEnd < text.length) snippet = '$snippet...';
    return snippet;
  }
}

class MatchSequence {
  final int start;
  final int end;
  final String rawText;

  const MatchSequence({
    required this.start,
    required this.end,
    required this.rawText,
  });
}
