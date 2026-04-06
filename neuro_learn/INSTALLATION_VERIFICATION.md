# Installation Verification Checklist

Use this checklist to verify that everything is set up correctly before running the app.

## ✅ Frontend Setup

### Dependencies Installed
```bash
# Run in project root
flutter pub get

# Verify installation
flutter pub list
```
Look for:
- ✅ record
- ✅ http
- ✅ path_provider
- ✅ permission_handler

### File Structure
Verify these files exist:

**lib/main.dart**
```bash
ls -la lib/main.dart
```

**lib/models/**
```bash
ls -la lib/models/
# Should show: story_model.dart, transcript_result.dart
```

**lib/services/**
```bash
ls -la lib/services/
# Should show: audio_service.dart, api_service.dart
```

**lib/screens/**
```bash
ls -la lib/screens/
# Should show: story_screen.dart
```

**lib/widgets/**
```bash
ls -la lib/widgets/
# Should show: highlighted_text.dart
```

### Updated pubspec.yaml
Check that dependencies are added:
```bash
grep -A 5 "dependencies:" pubspec.yaml | head -10
```

Should include: record, http, path_provider, permission_handler

## ✅ Backend Setup

### Node.js Installed
```bash
node --version   # Should be 14.0.0 or higher
npm --version    # Should be 6.0.0 or higher
```

### Backend Files
```bash
cd backend
ls -la
```

Should show:
- ✅ server.js
- ✅ package.json
- ✅ .env.example
- ✅ .gitignore
- ✅ README.md

### Backend Dependencies
```bash
cd backend
npm install

# Verify installation
npm list | head -20
```

Should show dependencies installed (express, multer, etc.)

## ✅ Configuration

### API Endpoint
Check that backend URL is configured correctly:
```bash
grep -n "baseUrl" lib/services/api_service.dart
```

Should show:
```
static const String baseUrl = 'http://localhost:3000/api';
```

Update if backend is at different location.

### Environment Variables (Backend)
```bash
cd backend
cat .env.example
```

Note required variables (backend can run without them using mock endpoint)

## ✅ Platform Configuration

### iOS Permissions
```bash
grep -A 2 "NSMicrophoneUsageDescription" ios/Runner/Info.plist
```

Should show microphone permission description

### Android Permissions
```bash
grep "RECORD_AUDIO" android/app/src/main/AndroidManifest.xml
```

Should show RECORD_AUDIO permission

## ✅ Documentation

Verify all documentation files exist:

```bash
# Main docs
ls -la FLUTTER_APP_README.md
ls -la IMPLEMENTATION_GUIDE.md
ls -la QUICK_START.md
ls -la PROJECT_SUMMARY.md
ls -la README.md

# Backend docs
ls -la backend/README.md
```

## 🧪 Pre-Flight Checks

### 1. Syntax Check
```bash
# Verify Dart syntax
cd /Users/sumitbahl/Sumit/NeuroLearn/neuro_learn
flutter analyze

# Should show no errors (warnings are ok)
```

### 2. Backend Health Check
```bash
cd backend
npm start &
BACKEND_PID=$!

# Wait 2 seconds
sleep 2

# Test health endpoint
curl http://localhost:3000/api/health

# Expected response:
# {"status":"ok","timestamp":"2024-...

# Kill backend
kill $BACKEND_PID
```

### 3. Build Check
```bash
# For iOS
flutter build ios --debug 2>&1 | tail -10

# For Android  
flutter build apk --debug 2>&1 | tail -10

# For Web
flutter build web 2>&1 | tail -10
```

## 🚀 Ready to Run!

Once all checkboxes above are verified, you can run:

### Terminal 1: Backend
```bash
cd backend
npm start
```

Wait for: "NeuroLearn Backend Server running on port 3000"

### Terminal 2: Frontend
```bash
flutter run -d ios   # or android/web
```

Wait for: "✓ Built build/ios/Debug-iphonesimulator/Runner.app"

### Terminal 3: Logs (Optional)
```bash
flutter logs
```

## ✅ Runtime Verification

Once app is running:

### 1. Story Displays
- [ ] Story text visible
- [ ] Story title in app bar
- [ ] Text is readable (16pt, line height 1.6)

### 2. Start Recording Button
- [ ] Blue "Start Recording" button visible
- [ ] Button is tappable
- [ ] Icon is microphone icon

### 3. Recording Works
- [ ] Tap "Start Recording"
- [ ] Button changes to "Stop Recording" (red)
- [ ] Timer appears and counts up
- [ ] Recording icon spins

### 4. Stop and Process
- [ ] Stop recording button stops timer
- [ ] State changes to "Processing"
- [ ] Loading spinner appears
- [ ] Message shows "Processing audio..."

### 5. Results Display
- [ ] Score card shows with percentage
- [ ] Stats show (Correct/Incorrect/Missing counts)
- [ ] Feedback message appears
- [ ] Word highlighting shows (green/red/amber)
- [ ] "Try Again" button appears

### 6. Try Again Works
- [ ] Tap "Try Again"
- [ ] Returns to "Ready" state
- [ ] Story is still visible
- [ ] Can record again

## 📋 Troubleshooting Checklist

| Symptom | Check |
|---------|-------|
| App won't compile | `flutter clean && flutter pub get` |
| Backend won't start | `cd backend && npm install && npm start` |
| Recording fails | Check microphone permission in Xcode/Android |
| No transcript | Verify backend URL and that server is running |
| Highlighting incorrect | Check comparison algorithm in api_service.dart |
| App crashes | `flutter logs` to see error messages |

## 📊 System Requirements

Verify your system meets these requirements:

```bash
# Check Flutter
flutter doctor

# Should show:
# ✓ Flutter (Channel stable, ...)
# ✓ Android toolchain (if deploying to Android)
# ✓ Xcode (if deploying to iOS)
# ✓ Chrome (if deploying to web)
```

## 🎓 Learning Resources

If you encounter issues, check:

1. **Documentation**
   - [QUICK_START.md](QUICK_START.md)
   - [FLUTTER_APP_README.md](FLUTTER_APP_README.md)
   - [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)

2. **External Resources**
   - Flutter: https://flutter.dev/docs
   - Dart: https://dart.dev
   - Node.js: https://nodejs.org/docs

3. **Package Documentation**
   - record: https://pub.dev/packages/record
   - http: https://pub.dev/packages/http
   - permission_handler: https://pub.dev/packages/permission_handler

## ✨ Success!

If all checks pass, you're ready to use NeuroLearn! 🎉

Next steps:
1. Add more stories (edit: lib/models/story_model.dart)
2. Integrate real speech-to-text service
3. Customize UI/colors as needed
4. Deploy to devices
5. Gather user feedback

Happy reading! 📖
