import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:neuro_learn/models/transcript_result.dart';

class ApiService {
  // Replace with your actual backend API URL
  static const String baseUrl = 'http://localhost:3000/api';

  Future<TranscriptResult?> sendAudioAndCompare(
    File audioFile,
    String originalStory,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/transcribe');
      final request = http.MultipartRequest('POST', uri);

      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
        ),
      );

      // Add original story
      request.fields['original_story'] = originalStory;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(responseBody);
        return _parseTranscriptResult(jsonData, originalStory);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error sending audio: $e');
      return null;
    }
  }

  TranscriptResult _parseTranscriptResult(
    Map<String, dynamic> data,
    String originalStory,
  ) {
    final transcript = data['transcript'] ?? '';
    final comparisons = _compareTranscript(transcript, originalStory);
    final score = _calculateScore(comparisons);
    final feedback = _generateFeedback(comparisons, score);

    return TranscriptResult(
      transcript: transcript,
      comparisons: comparisons,
      score: score,
      feedback: feedback,
    );
  }

  List<WordComparison> _compareTranscript(
    String transcript,
    String originalStory,
  ) {
    final originalWords = originalStory
        .toLowerCase()
        .replaceAll(RegExp(r'[.,!?;:]'), '')
        .split(RegExp(r'\s+'));

    final transcriptWords = transcript
        .toLowerCase()
        .replaceAll(RegExp(r'[.,!?;:]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final comparisons = <WordComparison>[];
    int transcriptIndex = 0;

    for (int i = 0; i < originalWords.length; i++) {
      final originalWord = originalWords[i];

      if (transcriptIndex < transcriptWords.length &&
          originalWord == transcriptWords[transcriptIndex]) {
        comparisons.add(WordComparison(
          word: originalWord,
          status: WordStatus.correct,
        ));
        transcriptIndex++;
      } else if (transcriptIndex < transcriptWords.length) {
        // Word is incorrect
        comparisons.add(WordComparison(
          word: originalWord,
          status: WordStatus.incorrect,
          userSaid: transcriptWords[transcriptIndex],
        ));
        transcriptIndex++;
      } else {
        // Word is missing
        comparisons.add(WordComparison(
          word: originalWord,
          status: WordStatus.missing,
        ));
      }
    }

    return comparisons;
  }

  double _calculateScore(List<WordComparison> comparisons) {
    if (comparisons.isEmpty) return 0;

    final correctCount =
        comparisons.where((c) => c.status == WordStatus.correct).length;

    // Score based on correct words (missing and incorrect count against the score)
    final totalWords = comparisons.length;
    return (correctCount / totalWords) * 100;
  }

  String _generateFeedback(List<WordComparison> comparisons, double score) {
    final correctCount =
        comparisons.where((c) => c.status == WordStatus.correct).length;
    final incorrectCount =
        comparisons.where((c) => c.status == WordStatus.incorrect).length;
    final missingCount =
        comparisons.where((c) => c.status == WordStatus.missing).length;

    String feedback =
        'Score: ${score.toStringAsFixed(1)}%\n\n';
    feedback += 'Correct: $correctCount | Incorrect: $incorrectCount | Missing: $missingCount\n\n';

    if (score >= 90) {
      feedback += '🎉 Excellent! You read the story perfectly!';
    } else if (score >= 75) {
      feedback += '👏 Great job! Just a few words to practice.';
    } else if (score >= 50) {
      feedback +=
          '💪 Good effort! Keep practicing to improve your reading.';
    } else {
      feedback += '📖 Keep practicing! You\'ll improve with time.';
    }

    return feedback;
  }
}
