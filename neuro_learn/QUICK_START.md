# NeuroLearn Quick Start Guide

Get the NeuroLearn app running in 15 minutes!

## 🚀 Quick Setup

### Step 1: Frontend - Get Flutter Dependencies (2 min)

```bash
cd /Users/sumitbahl/Sumit/NeuroLearn/neuro_learn
flutter pub get
```

### Step 2: Backend - Quick Mock Testing (3 min)

For testing without setting up Google Cloud, use the mock endpoint:

```bash
cd backend
npm install
npm start
```

Server will run at `http://localhost:3000`

Test the mock endpoint:
```bash
curl -X POST http://localhost:3000/api/transcribe-mock \
  -F "audio=@/path/to/test.m4a" \
  -F "original_story=The quick brown fox"
```

### Step 3: Update API Endpoint (if needed)

If backend is not at `localhost:3000`, update in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://your-ip:port/api';
```

### Step 4: Run the App

```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Web
flutter run -d web
```

## 📱 Testing the App

1. **Start Recording** - Tap the button to begin recording
2. **Read the Story** - Read text aloud: "The quick brown fox jumps over the lazy dog. This pangram contains every letter of the alphabet."
3. **Stop Recording** - Tap stop
4. **See Results** - View highlighting and score

## 🔧 Configuration

### Microphone Permissions

**iOS** (Already configured in Info.plist):
- App shows permission dialog on first use

**Android** (Already configured in AndroidManifest.xml):
- App requests permission at runtime

### Backend URL

For different environments:

```dart
// Development (local)
static const String baseUrl = 'http://localhost:3000/api';

// Staging
static const String baseUrl = 'http://api-staging.example.com/api';

// Production
static const String baseUrl = 'https://api.example.com/api';
```

## 📂 Project Structure

```
neuro_learn/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── story_model.dart
│   │   └── transcript_result.dart
│   ├── services/                 # Business logic
│   │   ├── audio_service.dart
│   │   └── api_service.dart
│   ├── screens/                  # Screens/Pages
│   │   └── story_screen.dart
│   └── widgets/                  # Reusable widgets
│       └── highlighted_text.dart
├── backend/                      # Node.js backend
│   ├── server.js
│   ├── package.json
│   └── README.md
├── pubspec.yaml                  # Flutter dependencies
└── FLUTTER_APP_README.md         # Full documentation
```

## 🔌 Backend Setup Details

### Using Mock Endpoint (No API Key Needed)

The app will work with the mock endpoint right away:

```bash
cd backend
npm install
npm start
```

The mock endpoint returns the same text as the input (perfect for testing).

### Using Real Speech-to-Text (Optional)

1. **Google Cloud Option:**
   ```bash
   # Create Google Cloud project
   # Enable Speech-to-Text API
   # Download service account credentials
   
   export GOOGLE_APPLICATION_CREDENTIALS="./credentials.json"
   npm start
   ```

2. **Alternative Services:**
   - Modify `server.js` to use AWS Transcribe, Azure, or Deepgram
   - Update API client in `backend/server.js`

## 🧪 Testing Steps

### Test 1: Check Backend Health
```bash
curl http://localhost:3000/api/health
```

Response:
```json
{"status":"ok","timestamp":"2024-04-05T10:30:00.000Z"}
```

### Test 2: Record a Test Audio (on device)
1. Run app on simulator
2. Start recording
3. Count to 10
4. Stop recording

### Test 3: Verify Results Display
- Check highlighting: Green (correct), Red (incorrect), Amber (missing)
- Score should be calculated
- Feedback message should appear

## ⚠️ Common Issues

| Problem | Solution |
|---------|----------|
| **Backend not responding** | Ensure `npm start` is running in another terminal |
| **API error 404** | Check `baseUrl` in `api_service.dart` matches backend |
| **Microphone not working** | Check device permissions, restart app |
| **No audio file created** | Verify device storage is writable, check logs |
| **App won't compile** | Run `flutter clean` then `flutter pub get` |

## 🎯 Next Steps

After getting it working:

1. **Add More Stories**
   - Edit `lib/models/story_model.dart`
   - Create story selection screen

2. **Integrate Real Speech-to-Text**
   - Set up Google Cloud credentials
   - Update backend `server.js`

3. **Enhance UI**
   - Add animations
   - Customize colors/fonts
   - Add sound effects

4. **Add Features**
   - Progress tracking
   - Multiple difficulties
   - Pronunciation coaching

## 📚 Full Documentation

- **FLUTTER_APP_README.md** - Complete Flutter app documentation
- **backend/README.md** - Complete backend documentation
- **IMPLEMENTATION_GUIDE.md** - Detailed architecture and implementation

## 💡 Tips

- Use `flutter run -v` for verbose logging
- Check device console: `flutter logs`
- Use `flutter devtools` for debugging
- Test backend with `curl` before running app
- Keep recording time short (< 30 seconds) for testing

## 🐛 Debugging

Enable debug logging:

```dart
// Add to api_service.dart
print('Response: $responseBody');

// Add to audio_service.dart
print('Recording to: $_recordingPath');
```

View Flutter logs:
```bash
flutter logs
```

## 🎓 Learning Resources

- Flutter Official: https://flutter.dev
- Dart Language: https://dart.dev
- HTTP Requests: https://pub.dev/packages/http
- Audio Recording: https://pub.dev/packages/record
- Google Cloud Speech: https://cloud.google.com/speech-to-text

---

**Ready to go? Start with Step 1 above!** 🚀
