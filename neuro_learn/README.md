# NeuroLearn - Story Reading Evaluation App

A Flutter application that helps users learn to read by recording their voice, comparing it with reference text, and providing instant feedback with visual highlighting of correct, incorrect, and missing words.

## 🎯 Features

- **📖 Story Display**: Clean, readable display of practice stories
- **🎙️ Audio Recording**: Easy recording with visual timer
- **🔄 Automatic Transcription**: Send audio to backend for processing
- **🎨 Visual Feedback**: Color-coded word highlighting:
  - 🟢 Green: Correct words
  - 🔴 Red: Incorrect words (shows what user said)
  - 🟡 Yellow: Missing words
- **📊 Detailed Results**:
  - Score (0-100%)
  - Stats (correct/incorrect/missing counts)
  - Personalized feedback
  - Word-by-word comparison
- **♻️ Multiple Attempts**: Try again feature for continuous practice

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10.9+
- Node.js 14+ (for backend)
- macOS/iOS or Android device/emulator

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Start Backend Server

```bash
cd backend
npm install
npm start
```

Server runs at `http://localhost:3000`

### 3. Run the App

```bash
flutter run -d ios    # for iOS
flutter run -d android # for Android
flutter run -d web     # for web
```

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - 15-minute setup guide
- **[FLUTTER_APP_README.md](FLUTTER_APP_README.md)** - Complete app documentation
- **[backend/README.md](backend/README.md)** - Backend setup and API docs
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Architecture and technical details
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Complete project overview

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── main.dart                 - App entry point
├── models/                  - Data structures
├── services/                - Business logic
├── screens/                 - UI screens
└── widgets/                 - Reusable components
```

### Backend (Node.js)
```
backend/
├── server.js               - Express server
├── package.json            - Dependencies
└── .env.example            - Configuration template
```

## 🔌 API

### Transcribe Audio
```bash
POST /api/transcribe
Content-Type: multipart/form-data

Fields:
- audio (file): M4A audio file
- original_story (string): Original story text

Response:
{
  "transcript": "transcribed text...",
  "original_story": "original text...",
  "processed_at": "2024-04-05T10:30:00.000Z"
}
```

## 🎬 How It Works

```
1. User sees story displayed
2. Taps "Start Recording"
3. Records their voice reading the story
4. Taps "Stop Recording"
5. App sends audio to backend
6. Backend transcribes the audio
7. App compares transcript with original
8. Results displayed with highlighting
9. User sees score, feedback, and word comparison
10. Can try again for another attempt
```

## 🛠️ Customization

### Add Story
Edit `lib/models/story_model.dart`:
```dart
final newStory = Story(
  title: "Story Title",
  content: "Your story text here...",
);
```

### Change Backend URL
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-api:3000/api';
```

### Customize Feedback
Edit `api_service.dart` → `_generateFeedback()` method

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ Full | iOS 11.0+ required |
| Android | ✅ Full | API 21+ required |
| Web | ⚠️ Limited | Demo only, CORS needed |
| macOS | ✅ Supported | Similar to iOS |

## ⚙️ Dependencies

### Frontend
- `record` - Audio recording
- `http` - HTTP client
- `path_provider` - File storage
- `permission_handler` - Permissions

### Backend
- `express` - Web framework
- `multer` - File upload
- `@google-cloud/speech` - Speech-to-text (optional)

## 🧪 Testing

### Test Recording
1. Run app
2. Tap "Start Recording"
3. Read the story aloud
4. Tap "Stop Recording"
5. Verify highlighting displays correctly

### Test Backend
```bash
curl -X POST http://localhost:3000/api/transcribe-mock \
  -F "audio=@test.m4a" \
  -F "original_story=Test story"
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Recording fails | Check microphone permission |
| Backend connection error | Verify backend is running at correct URL |
| Files not found | Run `flutter clean && flutter pub get` |
| Speech-to-text not working | Set up API credentials in backend |

## 📈 Performance

- Recording setup: < 1 second
- File size: 10-50 KB per recording
- Processing time: 1-5 seconds
- Memory usage: ~50 MB typical

## 🔒 Security

- Audio stored in app documents directory
- Runtime microphone permission required
- No telemetry by default
- Use HTTPS in production for API calls

## 🚢 Deployment

### iOS
```bash
flutter build ios
# Upload to TestFlight or App Store
```

### Android
```bash
flutter build apk
flutter build appbundle
# Upload to Play Store
```

### Backend
See [backend/README.md](backend/README.md) for deployment options (Heroku, Docker, etc.)

## 📞 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language](https://dart.dev/guides)
- [Record Package](https://pub.dev/packages/record)
- [HTTP Package](https://pub.dev/packages/http)
- [Google Cloud Speech-to-Text](https://cloud.google.com/speech-to-text)

## 📄 License

This project is provided for educational purposes.

## 👨‍💻 Development

### Project Structure
- Follows Flutter best practices
- Clean architecture with services
- Reactive state management
- Type-safe Dart code

### Code Style
- Follows Effective Dart guidelines
- Uses consistent naming conventions
- Comprehensive error handling
- Well-documented code

## ✨ Future Enhancements

- [ ] Multiple story categories
- [ ] Progress tracking and analytics
- [ ] Leaderboards
- [ ] Real-time feedback during recording
- [ ] Phoneme-level analysis
- [ ] Multiple language support
- [ ] Offline mode
- [ ] Cloud backup

## 🤝 Contributing

Contributions welcome! Areas for improvement:
- Additional speech recognition services
- More story content
- UI/UX enhancements
- Performance optimizations
- Additional languages
- Test coverage

---

**Get started with [QUICK_START.md](QUICK_START.md)** 🚀

