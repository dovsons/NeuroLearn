enum WordStatus { correct, incorrect, missing }

class WordComparison {
  final String word;
  final WordStatus status;
  final String? userSaid; // The word the user said (if incorrect)

  WordComparison({
    required this.word,
    required this.status,
    this.userSaid,
  });
}

class TranscriptResult {
  final String transcript;
  final List<WordComparison> comparisons;
  final double score; // 0-100
  final String feedback;

  TranscriptResult({
    required this.transcript,
    required this.comparisons,
    required this.score,
    required this.feedback,
  });

  int get correctCount => comparisons.where((c) => c.status == WordStatus.correct).length;
  int get incorrectCount =>
      comparisons.where((c) => c.status == WordStatus.incorrect).length;
  int get missingCount =>
      comparisons.where((c) => c.status == WordStatus.missing).length;
}
