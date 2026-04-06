import 'package:flutter/material.dart';
import 'package:neuro_learn/models/story_model.dart';
import 'package:neuro_learn/models/transcript_result.dart';
import 'package:neuro_learn/services/audio_service.dart';
import 'package:neuro_learn/services/api_service.dart';
import 'package:neuro_learn/widgets/highlighted_text.dart';

enum AppState { ready, recording, processing, results }

class StoryScreen extends StatefulWidget {
  final Story story;

  const StoryScreen({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  late AudioService _audioService;
  late ApiService _apiService;
  AppState _currentState = AppState.ready;
  TranscriptResult? _transcriptResult;
  String? _errorMessage;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _apiService = ApiService();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final success = await _audioService.startRecording();
    if (success) {
      setState(() {
        _currentState = AppState.recording;
        _recordingSeconds = 0;
      });
      _startTimer();
    } else {
      _showError('Failed to start recording. Please check microphone permissions.');
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _currentState == AppState.recording) {
        setState(() {
          _recordingSeconds++;
        });
        _startTimer();
      }
    });
  }

  Future<void> _stopRecording() async {
    final recordingPath = await _audioService.stopRecording();
    if (recordingPath != null) {
      setState(() {
        _currentState = AppState.processing;
        _errorMessage = null;
      });
      await _processAudio(recordingPath);
    } else {
      _showError('Failed to stop recording.');
    }
  }

  Future<void> _processAudio(String recordingPath) async {
    try {
      final audioFile = await _audioService.getRecordingFile();
      if (audioFile == null) throw Exception('Could not access recording file');

      final result = await _apiService.sendAudioAndCompare(
        audioFile,
        widget.story.content,
      );

      if (result != null) {
        setState(() {
          _transcriptResult = result;
          _currentState = AppState.results;
        });
      } else {
        _showError('Failed to process audio. Please try again.');
        setState(() {
          _currentState = AppState.ready;
        });
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
      setState(() {
        _currentState = AppState.ready;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _resetForNewAttempt() {
    setState(() {
      _currentState = AppState.ready;
      _transcriptResult = null;
      _errorMessage = null;
      _recordingSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Story Display Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Read the following story out loud:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Text(
                      widget.story.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recording Control Section
            _buildControlSection(),

            const SizedBox(height: 24),

            // Results Section
            if (_currentState == AppState.results && _transcriptResult != null)
              _buildResultsSection(),

            // Error Section
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Status Indicator
          if (_currentState == AppState.recording)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recording... ${_formatSeconds(_recordingSeconds)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            )
          else if (_currentState == AppState.processing)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Processing audio and generating transcript...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Buttons
          if (_currentState == AppState.ready)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.mic),
                label: const Text('Start Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          else if (_currentState == AppState.recording)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          else if (_currentState == AppState.results)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _resetForNewAttempt,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final result = _transcriptResult!;
    final scoreColor =
        result.score >= 75 ? Colors.green : Colors.deepOrange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: scoreColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Correct', result.correctCount, Colors.green),
                const SizedBox(width: 8),
                _buildStatColumn(
                    'Incorrect', result.incorrectCount, Colors.red),
                const SizedBox(width: 8),
                _buildStatColumn('Missing', result.missingCount, Colors.amber),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Feedback
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Text(
              result.feedback,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Transcript
          const Text(
            'Your Transcript:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              result.transcript,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Highlighted Comparison
          const Text(
            'Word-by-Word Comparison:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: HighlightedText(
              comparisons: result.comparisons,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 24),

          // Legend
          _buildLegend(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legend:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.3),
                border: Border.all(color: Colors.green),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Correct', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.3),
                border: Border.all(color: Colors.red),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Incorrect', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.amberAccent.withOpacity(0.3),
                border: Border.all(color: Colors.amber),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Missing', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  String _formatSeconds(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
