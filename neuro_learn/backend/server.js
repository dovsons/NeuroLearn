// Sample Backend Server for NeuroLearn App
// This is a simplified example using Google Cloud Speech-to-Text API
// You can replace the speech recognition service with any other provider

const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const speech = require('@google-cloud/speech');

const app = express();
const upload = multer({ dest: 'uploads/' });

// Initialize Speech-to-Text client
const client = new speech.SpeechClient();

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Transcribe audio endpoint
app.post('/api/transcribe', upload.single('audio'), async (req, res) => {
  try {
    const { original_story } = req.body;

    if (!req.file) {
      return res.status(400).json({ error: 'No audio file provided' });
    }

    if (!original_story) {
      return res.status(400).json({ error: 'No original_story provided' });
    }

    // Read the audio file
    const audioContent = fs.readFileSync(req.file.path);
    const base64Audio = audioContent.toString('base64');

    // Prepare the request for Google Cloud Speech-to-Text
    const request = {
      config: {
        encoding: 'LINEAR16', // Adjust based on your audio format
        sampleRateHertz: 16000,
        languageCode: 'en-US',
      },
      audio: {
        content: base64Audio,
      },
    };

    // Recognize speech from audio
    const [response] = await client.recognize(request);
    const transcription = response.results
      .map((result) =>
        result.alternatives[0] ? result.alternatives[0].transcript : ''
      )
      .join('\n')
      .toLowerCase();

    // Clean up uploaded file
    fs.unlinkSync(req.file.path);

    // Return the transcript
    res.json({
      transcript: transcription,
      original_story: original_story,
      processed_at: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Error processing audio:', error);
    res.status(500).json({
      error: 'Failed to process audio',
      message: error.message,
    });
  }
});

// Mock endpoint for testing (when Google Cloud credentials are not available)
app.post('/api/transcribe-mock', upload.single('audio'), (req, res) => {
  try {
    const { original_story } = req.body;

    if (!req.file) {
      return res.status(400).json({ error: 'No audio file provided' });
    }

    if (!original_story) {
      return res.status(400).json({ error: 'No original_story provided' });
    }

    // Mock transcript - in real implementation, use actual speech-to-text
    const mockTranscript = original_story.toLowerCase();

    // Clean up uploaded file
    fs.unlinkSync(req.file.path);

    // Return the mock transcript
    res.json({
      transcript: mockTranscript,
      original_story: original_story,
      processed_at: new Date().toISOString(),
      mock: true,
    });
  } catch (error) {
    console.error('Error processing audio:', error);
    res.status(500).json({
      error: 'Failed to process audio',
      message: error.message,
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`NeuroLearn Backend Server running on port ${PORT}`);
  console.log(
    `Use POST ${PORT}/api/transcribe with audio file and original_story`
  );
  console.log(`Or use POST ${PORT}/api/transcribe-mock for testing`);
});
