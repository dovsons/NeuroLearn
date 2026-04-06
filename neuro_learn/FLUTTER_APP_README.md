# NeuroLearn - Story Reading Evaluation App

A Flutter app that helps users learn to read by recording their voice as they read a story, then comparing their recording with the original text.

## Features

- 📖 **Story Display**: Beautiful, clear display of the story to read
- 🎙️ **Audio Recording**: Easy-to-use recording interface with timer
- 🔄 **Transcript Processing**: Sends audio to backend API for transcription
- 🎨 **Visual Feedback**: Color-coded word comparison (correct, incorrect, missing)
- 📊 **Detailed Results**: Score, statistics, and personalized feedback
- 🎯 **Multiple Attempts**: Try again feature for continuous learning

## Architecture

### Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── story_model.dart          # Story data model
│   └── transcript_result.dart    # Transcript comparison results
├── services/
│   ├── audio_service.dart        # Audio recording logic
│   └── api_service.dart          # API communication & transcript comparison
├── screens/
│   └── story_screen.dart         # Main app screen
└── widgets/
    └── highlighted_text.dart     # Word highlighting widget
```

### State Management

The app uses 4 main states:
1. **Ready**: Initial state, ready to start recording
2. **Recording**: Audio is being recorded
3. **Processing**: Audio is sent to backend, waiting for transcript
4. **Results**: Showing comparison results and feedback

### Audio Recording

- Uses the `record` package for cross-platform audio support
- Saves recordings in M4A format (AAC encoded)
- 16kHz sample rate for optimal speech recognition
- Automatic permission handling

## Backend API Requirements

The app expects a backend API endpoint at: `http://localhost:3000/api/transcribe`

### API Endpoint Specification

**POST** `/api/transcribe`

**Request:**
- Multipart form data
- `audio` (file): Audio file in M4A format
- `original_story` (string): The original story text

**Response:**
```json
{
  "transcript": "the quick brown fox jumps over the lazy dog this pangram contains every letter of the alphabet"
}
```

## Sample Backend Implementation

### Node.js/Express Example

See the `backend/` directory for a complete sample implementation using:
- Express.js
- Google Cloud Speech-to-Text API (or any other speech recognition service)

### Quick Start for Backend

1. Install Node.js dependencies:
   ```bash
   cd backend
   npm install
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your API credentials
   ```

3. Start the server:
   ```bash
   npm start
   ```

The server will run on `localhost:3000`

## Frontend Setup

### Prerequisites
- Flutter SDK 3.10.9 or higher
- Dart SDK (included with Flutter)

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Set microphone permissions (iOS & Android):
   
   **iOS (ios/Runner/Info.plist):**
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>NeuroLearn needs access to your microphone to record your voice while reading stories.</string>
   ```

   **Android (android/app/src/main/AndroidManifest.xml):**
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   ```

3. Run the app:
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   
   # For Web
   flutter run -d web
   ```

## Dependencies

### Core Dependencies
- **record** (^5.0.0): Audio recording across platforms
- **http** (^1.1.0): HTTP API communication
- **path_provider** (^2.1.0): File system access
- **permission_handler** (^11.4.4): Runtime permissions

## Transcript Comparison Algorithm

The app compares the user's transcript with the original story by:

1. **Normalization**: Converting to lowercase and removing punctuation
2. **Tokenization**: Splitting into words
3. **Sequential Matching**: Comparing word-by-word in order
4. **Classification**: Marking each word as:
   - ✅ **Correct**: Word matches exactly
   - ❌ **Incorrect**: User said a different word
   - ⚠️ **Missing**: User didn't say this word

5. **Scoring**: Score = (Correct Words / Total Words) × 100

## UI Components

### HighlightedText Widget
Displays word-by-word comparison with color coding:
- Green background: Correct words
- Red background: Incorrect words (with what user said)
- Amber background: Missing words

### StoryScreen Widget
Main screen containing:
- Story display section
- Recording control buttons
- Status indicators (recording, processing)
- Results section with score, stats, and visualization

## Customization

### Adding New Stories

Edit `lib/models/story_model.dart`:

```dart
final anotherStory = Story(
  title: "Your Story Title",
  content: "Your story content here...",
);
```

Then update `main.dart` to use the desired story.

### Changing the API Endpoint

Edit `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com/api';
```

### Customizing Feedback

Modify the `_generateFeedback()` method in `api_service.dart` to change scoring thresholds and messages.

## Permissions

The app requires the following permissions:

**iOS:**
- Microphone access (NSMicrophoneUsageDescription)

**Android:**
- RECORD_AUDIO
- WRITE_EXTERNAL_STORAGE (API < 30)

The app will request these permissions at runtime using `permission_handler`.

## Troubleshooting

### Recording not working
- Check that microphone permissions are granted
- Verify the device microphone is working
- Check app logs for detailed error messages

### No transcript received
- Ensure backend API is running and accessible
- Check the API endpoint URL in `api_service.dart`
- Verify audio file is in the correct format
- Check server logs for errors

### App crashes on startup
- Run `flutter clean` and `flutter pub get`
- Delete build folder and rebuild
- Check that all imports are correct

## Performance Considerations

- Audio recording uses hardware-accelerated codecs (M4A/AAC)
- UI remains responsive during processing with loading indicators
- Comparison algorithm is O(n) where n is number of words
- Results are displayed incrementally for large files

## Future Enhancements

- 📚 Multiple story selection
- 🏆 Progress tracking and leaderboards
- 🎵 Speed/fluency metrics
- 📈 Detailed analytics dashboard
- 🌍 Multi-language support
- ☁️ Cloud storage for recordings and results
- 🤖 Real-time feedback during recording

## License

This project is provided as-is for educational purposes.

## Support

For issues, questions, or suggestions, please check:
1. The troubleshooting section above
2. Flutter documentation: https://flutter.dev/docs
3. Package documentation:
   - record: https://pub.dev/packages/record
   - http: https://pub.dev/packages/http
