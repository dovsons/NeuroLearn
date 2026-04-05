# NeuroLearn – Assistive Learning App (MVP)

NeuroLearn is an AI-powered assistive learning platform designed to support children with learning differences such as dyslexia, ADHD, and dyscalculia.

This repository contains the initial MVP focused on **Speech-to-Text (STT)** and assistive writing tools.

---

## 🚀 Features (MVP)

### 🎤 Speech-to-Text (STT)
- Convert speech to text using local models (Whisper)
- Supports short answers and guided input
- Editable transcripts

### ✍️ Assistive Writing
- Basic text editor for responses
- Future support for:
  - Word prediction
  - Grammar assistance

### 🧠 Learning Support (Planned)
- Personalized feedback
- Error detection and correction
- Progress tracking

---

## 🏗️ Architecture (MVP)
Client (Web / Mobile) -> Backend API (Python) -> STT Engine (Whisper)



### Design Principles:
- Modular STT layer (easy to swap with cloud providers later)
- Simple API-first backend
- Extensible for future AI features

---

## 🛠️ Tech Stack

- **Backend:** Python (FastAPI recommended)
- **STT Engine:** OpenAI Whisper
- **Frontend:** (TBD – React / Mobile)
- **Storage:** Local / Cloud (future)

---

## Roadmap
### Phase 1 (Current)
- Basic STT using Whisper
- API endpoint for transcription
- Simple UI for testing
## Phase 2
- Real-time transcription (streaming)
- Word prediction
- Error correction layer
## Phase 3
- Cloud STT integration (GCP/AWS)
- Personalization engine
- Parent/teacher dashboard