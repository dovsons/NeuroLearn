# NeuroLearn Implementation Guide

This document provides detailed information about the architecture and implementation of the NeuroLearn app.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Frontend                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Story Screen (UI Layer)                  │ │
│  │  - Display story                                      │ │
│  │  - Show recording state                              │ │
│  │  - Display results with highlighting                │ │
│  └────────────────────────────────────────────────────────┘ │
│            ↓                                ↑                │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Service Layer (Business Logic)               │ │
│  │  - AudioService: Handle recording                    │ │
│  │  - ApiService: Communicate with backend             │ │
│  │  - Comparison algorithm                              │ │
│  └────────────────────────────────────────────────────────┘ │
│            ↓                                ↑                │
│  ┌────────────────────────────────────────────────────────┐ │
│  │          Models (Data Structures)                     │ │
│  │  - Story: Title + content                            │ │
│  │  - TranscriptResult: Comparison results              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                         ↓        ↑
           HTTP/Multipart Form Data
                         ↓        ↑
┌─────────────────────────────────────────────────────────────┐
│                    Node.js Backend                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         Express Route Handlers                        │ │
│  │  - /api/health: Health check                         │ │
│  │  - /api/transcribe: Process audio                    │ │
│  │  - /api/transcribe-mock: Mock endpoint               │ │
│  └────────────────────────────────────────────────────────┘ │
│            ↓                                ↑                │
│  ┌────────────────────────────────────────────────────────┐ │
│  │    Speech-to-Text Service Integration               │ │
│  │  - Google Cloud Speech-to-Text (recommended)         │ │
│  │  - AWS Transcribe (alternative)                      │ │
│  │  - Other STT services                                │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Recording and Submission Flow

```
1. User clicks "Start Recording"
   ↓
2. AudioService requests microphone permission
   ↓
3. Recording starts, timer increments
   ↓
4. User reads the story aloud
   ↓
5. User clicks "Stop Recording"
   ↓
6. Audio file is saved locally
   ↓
7. State changes to "Processing"
   ↓
8. ApiService prepares multipart request
   ├─ Audio file
   └─ Original story text
   ↓
9. File is uploaded to backend
   ↓
10. Backend processes with speech-to-text
    ↓
11. Backend returns transcript
    ↓
12. ApiService performs comparison
    ├─ Normalize both texts
    ├─ Split into words
    ├─ Compare word by word
    └─ Mark as correct/incorrect/missing
    ↓
13. Calculate score and feedback
    ↓
14. State changes to "Results"
    ↓
15. UI displays results with highlighting
```

## Component Details

### 1. Story Screen (lib/screens/story_screen.dart)

**Responsibilities:**
- Display the story text
- Manage app state (ready, recording, processing, results)
- Handle user interactions (button taps)
- Display results and statistics

**Key Methods:**
```dart
_startRecording()      // Start audio recording
_stopRecording()       // Stop recording and send to backend
_processAudio()        // Handle backend response
_resetForNewAttempt()  // Reset for another try
```

**State Variables:**
```dart
_currentState         // Current app state (AppState enum)
_transcriptResult     // Result from backend
_recordingSeconds     // Timer for recording duration
_errorMessage         // Error display
```

### 2. Audio Service (lib/services/audio_service.dart)

**Responsibilities:**
- Request and manage microphone permissions
- Record audio to device storage
- Retrieve recorded file for upload

**Key Methods:**
```dart
requestMicrophonePermission()  // Request runtime permission
startRecording()                // Start recording to file
stopRecording()                 // Stop recording and return path
isRecording()                   // Check if currently recording
getRecordingFile()              // Get File object for upload
dispose()                       // Clean up resources
```

**Audio Configuration:**
- Format: M4A (AAC encoded)
- Sample Rate: 16000 Hz (optimal for speech recognition)
- Channels: Mono
- File storage: App documents directory

### 3. API Service (lib/services/api_service.dart)

**Responsibilities:**
- Send audio file to backend
- Receive transcript
- Compare transcript with original story
- Calculate score and generate feedback

**Key Methods:**
```dart
sendAudioAndCompare(File, String)  // Main method
_parseTranscriptResult()            // Parse backend response
_compareTranscript()                // Word-by-word comparison
_calculateScore()                   // Compute score
_generateFeedback()                 // Create feedback message
```

**Comparison Algorithm:**

1. **Normalization:**
   - Convert to lowercase
   - Remove punctuation (.,!?;:)
   - Split by whitespace (regex: `\s+`)

2. **Matching:**
   ```
   For each word in original story:
     If user said the same word → CORRECT
     Else if user said different word → INCORRECT
     Else if no more words from user → MISSING
   ```

3. **Scoring:**
   ```
   Score = (Correct Words / Total Words) × 100
   ```

4. **Classification:**
   - ✅ Correct: 0-100 words (green)
   - ❌ Incorrect: 75-90 (red)
   - ⚠️ Missing: 50-75 (amber)

### 4. Models

**Story Model (lib/models/story_model.dart):**
```dart
class Story {
  final String title;
  final String content;
  
  Story({required this.title, required this.content});
  
  List<String> get words => content.split(RegExp(r'\s+'));
}
```

**Transcript Result (lib/models/transcript_result.dart):**
```dart
class WordComparison {
  final String word;           // Original word
  final WordStatus status;     // correct/incorrect/missing
  final String? userSaid;      // What user said (if incorrect)
}

class TranscriptResult {
  final String transcript;
  final List<WordComparison> comparisons;
  final double score;          // 0-100
  final String feedback;
  
  // Computed properties
  int get correctCount;
  int get incorrectCount;
  int get missingCount;
}
```

### 5. Widgets

**HighlightedText (lib/widgets/highlighted_text.dart):**
- Displays word-by-word comparison
- Color codes by status
- Shows user's incorrect words
- Marks missing words

**Story Screen Widgets:**
- Control section with buttons
- Status indicators (recording, processing)
- Results section with score, stats, feedback
- Highlighted text display
- Legend for colors

## API Integration

### Request Format

```
POST /api/transcribe
Content-Type: multipart/form-data

audio: [Binary M4A file]
original_story: "The quick brown fox..."
```

### Response Format

```json
{
  "transcript": "the quick brown fox jumps over the lazy dog this pangram contains every letter of the alphabet",
  "original_story": "The quick brown fox jumps over the lazy dog. This pangram contains every letter of the alphabet.",
  "processed_at": "2024-04-05T10:30:00.000Z"
}
```

## UI States and Transitions

```
┌──────────────────────────────────────────────────────────┐
│                        READY                             │
│  - Show: Story text, Start Recording button             │
│  - User action: Click Start Recording                   │
│  - Next: RECORDING                                      │
└──────────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────────┐
│                      RECORDING                           │
│  - Show: Story text, Stop Recording button, Timer      │
│  - User action: Click Stop Recording                    │
│  - Next: PROCESSING                                     │
└──────────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────────┐
│                     PROCESSING                           │
│  - Show: Loading spinner, "Processing..." message       │
│  - Backend processing audio                             │
│  - Comparison algorithm running                         │
│  - Next: RESULTS (on success) or READY (on error)      │
└──────────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────────┐
│                      RESULTS                             │
│  - Show: Score card, stats, feedback, highlighting     │
│  - User action: Click Try Again                         │
│  - Next: READY                                          │
└──────────────────────────────────────────────────────────┘
```

## Error Handling

### Permission Denied
```dart
if (!hasPermission) {
  showError('Microphone permission required');
  return false;
}
```

### Recording Failure
```dart
if (recordingPath == null) {
  showError('Failed to stop recording');
}
```

### Network Error
```dart
try {
  final result = await _apiService.sendAudioAndCompare(...);
} catch (e) {
  showError('Failed to process audio: ${e.toString()}');
}
```

## Performance Optimization

### Audio Processing
- M4A format provides 4-6x compression vs WAV
- 16kHz sample rate balances quality and file size
- Mono reduces file size vs stereo

### UI Responsiveness
- Use async/await for long operations
- Show loading indicators during processing
- Disable buttons during operations

### Memory Management
- Dispose of controllers and services
- Delete recording files after upload
- Clear large objects when not needed

## Testing Strategy

### Unit Tests
```dart
// Test comparison algorithm
test('CompareTranscript correctly identifies errors', () {
  final original = "the quick fox";
  final transcript = "the quick frog";
  
  final comparisons = _compareTranscript(transcript, original);
  
  expect(comparisons[0].status, WordStatus.correct);
  expect(comparisons[2].status, WordStatus.incorrect);
});
```

### Integration Tests
```dart
// Test recording flow
testWidgets('Recording workflow', (WidgetTester tester) async {
  await tester.pumpWidget(const NeuroLearnApp());
  
  // Tap start recording
  await tester.tap(find.byIcon(Icons.mic));
  await tester.pumpAndSettle();
  
  // Verify recording state
  expect(find.byIcon(Icons.stop), findsOneWidget);
});
```

## Deployment Checklist

- [ ] Finish backend API implementation
- [ ] Test audio recording on both iOS and Android
- [ ] Verify microphone permissions work correctly
- [ ] Test with various audio quality levels
- [ ] Implement error recovery
- [ ] Add analytics tracking
- [ ] Optimize audio compression
- [ ] Handle network timeouts
- [ ] Test with long stories
- [ ] Add user feedback mechanism
- [ ] Secure API endpoints
- [ ] Add rate limiting to backend
- [ ] Implement logging/monitoring
- [ ] Test on various devices

## Customization Examples

### Adding a New Story
```dart
final shakespearStory = Story(
  title: "Romeo and Juliet",
  content: "O Romeo, Romeo! Wherefore art thou Romeo?...",
);
```

### Changing Feedback Threshold
```dart
if (score >= 95) {
  feedback = '⭐ Perfect!';
} else if (score >= 85) {
  feedback = '👍 Excellent!';
} // ... more thresholds
```

### Customizing Colors
```dart
const correctColor = Color(0xFF4CAF50);  // Green
const incorrectColor = Color(0xFFF44336); // Red
const missingColor = Color(0xFFFFC107);   // Amber
```

## Troubleshooting Guide

| Issue | Solution |
|-------|----------|
| Recording not working | Check permissions in device settings |
| No transcript received | Verify backend is running and URL is correct |
| Comparison is incorrect | Review word normalization logic |
| App crashes | Check stack trace in Flutter debug console |
| UI not updating | Ensure setState() is called properly |

## Future Roadmap

1. **Phase 1 (Current)**
   - Basic story reading with recording
   - Single story support
   - Simple scoring

2. **Phase 2**
   - Multiple story selection
   - Real-time feedback during recording
   - Pronunciation analysis

3. **Phase 3**
   - Progress tracking
   - Leaderboards
   - Multiple languages
   - Advanced analytics

4. **Phase 4**
   - Adaptive difficulty
   - Personalized recommendations
   - Community features
   - Offline support
