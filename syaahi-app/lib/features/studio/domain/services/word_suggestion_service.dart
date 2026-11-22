import '../models/writing_intelligence_models.dart';

/// Lightweight local offline thesaurus & poetic vocabulary resource.
class WordSuggestionService {
  /// Curated poetic dictionary map (lowercase key -> list of alternatives).
  static const Map<String, List<String>> _poeticDictionary = {
    // Aesthetics & Beauty
    'beautiful': ['elegant', 'radiant', 'graceful', 'exquisite', 'mesmerising', 'stunning'],
    'pretty': ['charming', 'delicate', 'lovely', 'fair', 'picturesque'],
    'gorgeous': ['resplendent', 'breathtaking', 'magnificent', 'dazzling'],

    // Darkness, Night & Shadows
    'dark': ['dim', 'shadowed', 'obscure', 'somber', 'tenebrous', 'gloomy', 'twilit'],
    'night': ['dusk', 'twilight', 'midnight', 'eventide', 'nocturne', 'shadow-fall'],
    'shadow': ['shade', 'silhouette', 'penumbra', 'phantom', 'gloom'],

    // Light & Brilliance
    'bright': ['luminous', 'incandescent', 'radiant', 'gleaming', 'brilliant', 'vibrant'],
    'light': ['illumination', 'glow', 'gleam', 'ray', 'luster', 'beam'],

    // Emotion, Sorrow & Joy
    'sad': ['melancholic', 'sorrowful', 'wistful', 'mournful', 'desolate', 'somber'],
    'happy': ['blissful', 'elated', 'joyous', 'radiant', 'buoyant', 'jubilantly'],
    'lonely': ['solitary', 'desolate', 'isolated', 'sequestered', 'unaccompanied'],

    // Silence, Quiet & Sound
    'quiet': ['hushed', 'silent', 'tranquil', 'placid', 'serene', 'still'],
    'silent': ['hushed', 'mute', 'soundless', 'untroubled', 'peaceful'],
    'whisper': ['murmur', 'breathe', 'susurrus', 'rustle', 'soft call'],

    // Nature, Wind & Water
    'wind': ['breeze', 'zephyr', 'gale', 'draft', 'whispering air'],
    'river': ['stream', 'brook', 'current', 'flow', 'tributary'],
    'sky': ['heavens', 'firmament', 'azure', 'canopy', 'ether'],

    // Transliterated Hindi poetic words
    'raat': ['shab', 'sandhya', 'andhera', 'nishaa'],
    'dil': ['mann', 'jigar', 'hirday', 'rooh'],
    'pyaar': ['mohabbat', 'ulfat', 'ishq', 'preeti'],
    'andhera': ['taariqi', 'saaya', 'k darkness'],
    'roshni': ['noor', 'ujala', 'prakash', 'kiran'],
  };

  /// Main word alternative lookup.
  static List<WritingSuggestion> findSuggestionsForSelection(
    String text, {
    required int selectionStart,
    required int selectionEnd,
  }) {
    if (text.isEmpty || selectionStart < 0 || selectionEnd > text.length) {
      return const [];
    }

    String selectedText;
    int actualStart;
    int actualEnd;

    if (selectionStart == selectionEnd) {
      // No selection highlighted; resolve word under cursor
      final wordMatch = _resolveWordAtOffset(text, selectionStart);
      if (wordMatch == null) return const [];

      selectedText = wordMatch.word;
      actualStart = wordMatch.start;
      actualEnd = wordMatch.end;
    } else {
      selectedText = text.substring(selectionStart, selectionEnd).trim();
      actualStart = selectionStart;
      actualEnd = selectionEnd;
    }

    final normalized = selectedText.toLowerCase();
    final alternatives = _poeticDictionary[normalized];

    if (alternatives == null || alternatives.isEmpty) {
      return const [];
    }

    return [
      WritingSuggestion(
        id: 'word_sug_${normalized}_$actualStart',
        type: WritingIssueType.wordSuggestion,
        originalText: selectedText,
        explanation:
            'Alternative word options for "$selectedText" to enrich poetic resonance:',
        startOffset: actualStart,
        endOffset: actualEnd,
        alternatives: alternatives,
        contextSnippet: text.substring(
          (actualStart - 15) < 0 ? 0 : actualStart - 15,
          (actualEnd + 15) > text.length ? text.length : actualEnd + 15,
        ),
      ),
    ];
  }

  /// Finds suggestions across an entire document for recognized words.
  static List<WritingSuggestion> analyzeDocument(String text) {
    if (text.trim().isEmpty) return const [];

    final suggestions = <WritingSuggestion>[];
    final wordRegex = RegExp(r'\b([a-zA-Z\u0900-\u097F]+)\b');

    for (final match in wordRegex.allMatches(text)) {
      final raw = match.group(1)!;
      final normalized = raw.toLowerCase();

      if (_poeticDictionary.containsKey(normalized)) {
        final alternatives = _poeticDictionary[normalized]!;

        suggestions.add(WritingSuggestion(
          id: 'doc_word_sug_${normalized}_${match.start}',
          type: WritingIssueType.wordSuggestion,
          originalText: raw,
          explanation: 'Explore alternative poetic choices for "$raw":',
          startOffset: match.start,
          endOffset: match.end,
          alternatives: alternatives,
        ));
      }
    }

    return suggestions;
  }

  static WordOffsetMatch? _resolveWordAtOffset(String text, int offset) {
    final wordRegex = RegExp(r'\b([a-zA-Z\u0900-\u097F]+)\b');
    for (final match in wordRegex.allMatches(text)) {
      if (offset >= match.start && offset <= match.end) {
        return WordOffsetMatch(
          word: match.group(1)!,
          start: match.start,
          end: match.end,
        );
      }
    }
    return null;
  }
}

class WordOffsetMatch {
  final String word;
  final int start;
  final int end;

  WordOffsetMatch({required this.word, required this.start, required this.end});
}
