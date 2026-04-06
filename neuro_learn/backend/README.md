# NeuroLearn Backend Server

Backend service for the NeuroLearn Flutter app that handles audio transcription and processing.

## Overview

This backend server:
- Receives audio files from the Flutter app
- Converts speech to text using a speech recognition service
- Returns the transcript to the Flutter app
- Handles error cases gracefully

## Setup Instructions

### Prerequisites

- Node.js 14.0.0 or higher
- npm or yarn
- Google Cloud Account (for Google Cloud Speech-to-Text) or alternative speech service

### Installation

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   ```bash
   cp .env.example .env
   ```

4. Edit `.env` with your configuration:
   - Set `PORT` if you want to use a different port (default: 3000)
   - Add your speech-to-text service credentials

### Configuring Google Cloud Speech-to-Text

1. Create a Google Cloud Project
2. Enable the Cloud Speech-to-Text API
3. Create a service account and download the JSON credentials
4. Point `GOOGLE_APPLICATION_CREDENTIALS` to your credentials file:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="./path/to/your/credentials.json"
   ```

### Running the Server

#### Development Mode
```bash
npm run dev
```
This uses nodemon for auto-restart on file changes.

#### Production Mode
```bash
npm start
```

The server will be available at `http://localhost:3000`

## API Endpoints

### Health Check
**GET** `/api/health`

Check if the server is running.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-04-05T10:30:00.000Z"
}
```

### Transcribe Audio
**POST** `/api/transcribe`

Transcribe audio file using the configured speech-to-text service.

**Request:**
- Multipart form data
- `audio` (file): Audio file (M4A format recommended)
- `original_story` (string): The original story text for reference

**Response:**
```json
{
  "transcript": "the quick brown fox jumps over the lazy dog",
  "original_story": "The quick brown fox jumps over the lazy dog.",
  "processed_at": "2024-04-05T10:30:00.000Z"
}
```

**Error Response:**
```json
{
  "error": "Error message",
  "message": "Detailed error description"
}
```

### Mock Transcribe (for testing)
**POST** `/api/transcribe-mock`

Same as above, but returns a mocked transcript (useful for testing without speech-to-text service).

**Response:**
```json
{
  "transcript": "the quick brown fox jumps over the lazy dog",
  "original_story": "The quick brown fox jumps over the lazy dog.",
  "processed_at": "2024-04-05T10:30:00.000Z",
  "mock": true
}
```

## Testing the API

### Using cURL

Test the mock endpoint:
```bash
curl -X POST http://localhost:3000/api/transcribe-mock \
  -F "audio=@path/to/your/audio.m4a" \
  -F "original_story=The quick brown fox jumps over the lazy dog"
```

### Using Postman

1. Create a new POST request to `http://localhost:3000/api/transcribe`
2. In the Body tab, select "form-data"
3. Add:
   - Key: `audio`, Type: File, Value: Select your audio file
   - Key: `original_story`, Type: Text, Value: Your story text
4. Click Send

## Deployment

### Using Heroku

1. Create a Heroku app:
   ```bash
   heroku create your-app-name
   ```

2. Set environment variables:
   ```bash
   heroku config:set GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
   ```

3. Deploy:
   ```bash
   git push heroku main
   ```

### Using Docker

1. Create a Dockerfile:
   ```dockerfile
   FROM node:18-alpine
   WORKDIR /app
   COPY package*.json ./
   RUN npm install
   COPY . .
   EXPOSE 3000
   CMD ["npm", "start"]
   ```

2. Build and run:
   ```bash
   docker build -t neuro-learn-backend .
   docker run -p 3000:3000 -e PORT=3000 neuro-learn-backend
   ```

## Speech-to-Text Service Options

### Google Cloud Speech-to-Text (Recommended)
- Highly accurate speech recognition
- Supports multiple languages
- Billing: ~$0.024 per 15 seconds of audio

### Alternative Services
- **AWS Transcribe**: Amazon's transcription service
- **Azure Speech Services**: Microsoft's speech API
- **Deepgram**: Modern speech-to-text API
- **AssemblyAI**: Conversational AI speech-to-text

## Troubleshooting

### "Failed to process audio" error
- Ensure audio file is in supported format (M4A, WAV, etc.)
- Check that the file is not corrupted
- Verify speech-to-text service credentials are correct

### Server not starting
- Check if port 3000 is already in use
- Verify Node.js is properly installed
- Check for missing dependencies: `npm install`

### Authentication errors
- Verify service credentials are correctly set in `.env`
- Check that credentials file has read permissions
- Ensure service account has necessary API permissions

### Audio file too large errors
- Compress audio or reduce recording duration
- Consider sending files in chunks for very long recordings

## Performance Optimization

### Audio File Size
- Use M4A format for smaller file sizes
- 16kHz sample rate is optimal for speech recognition
- Mono audio is sufficient (no need for stereo)

### Batch Processing
- Consider implementing job queues for high traffic
- Use message queues (Redis, RabbitMQ) for async processing

### Caching
- Cache frequently requested transcripts
- Implement CDN for static responses

## Security Considerations

1. **Authentication**: Add API key validation in production
2. **Rate Limiting**: Implement rate limiting to prevent abuse
3. **Input Validation**: Validate all inputs (file size, type, etc.)
4. **Encryption**: Use HTTPS in production
5. **File Storage**: Securely handle and delete audio files
6. **Credentials**: Never commit credentials to version control

## Monitoring

### Logging
The server logs all requests and errors. Check logs:
```bash
npm run dev  # Shows logs in console
```

### Error Tracking
Consider integrating with services like:
- Sentry for error monitoring
- DataDog for performance monitoring
- CloudWatch for AWS deployment

## Future Enhancements

- [ ] Batch processing for multiple audios
- [ ] Caching layer for repeated stories
- [ ] Advanced audio preprocessing
- [ ] Multiple language support
- [ ] Detailed pronunciation feedback
- [ ] Audio quality assessment
- [ ] Real-time transcription streaming

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Google Cloud Speech-to-Text documentation
3. Check Node.js server logs for detailed errors

## License

This project is provided as-is for educational purposes.
