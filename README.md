# Connect

Real-time chat application with Google Sign-In. Node.js/Express + Socket.io backend, Flutter mobile frontend.

**Repository:** https://github.com/mahmudul-hasan-exe/Connect

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Technology Stack & Versions](#technology-stack--versions)
4. [Project Structure](#project-structure)
5. [Setup & Installation](#setup--installation)
6. [Configuration](#configuration)
7. [Running the Application](#running-the-application)
8. [API Reference](#api-reference)
9. [Integration Guide](#integration-guide)
10. [Contributing](#contributing)

---

## Overview

Connect is an open-source real-time chat application that uses:

- **Backend:** Node.js, Express, MongoDB, Socket.io
- **Frontend:** Flutter (mobile/cross-platform)
- **Auth:** Supabase with Google Sign-In
- **Real-time:** Socket.io for messaging, typing indicators, online status

---

## Features

| Category | Description |
|----------|-------------|
| **Auth** | Google Sign-In via Supabase, onboarding, session persistence |
| **Profile** | Name, avatar, online/offline status, logout |
| **Connections** | Send/accept connection requests before starting a chat |
| **Chat** | Chat list, unread count, real-time messaging, sent/delivered status |
| **Real-time** | Typing indicator, online status, last seen |
| **Privacy** | Block/unblock users, in-chat block banners |
| **UX** | Notification screen, unread and request badges |

---

## Technology Stack & Versions

### Backend (Node.js)

| Package | Version | Purpose |
|---------|---------|---------|
| Node.js | 18+ | Runtime |
| express | ^4.18.2 | Web framework |
| socket.io | ^4.7.2 | Real-time communication |
| mongoose | ^8.0.3 | MongoDB ODM |
| jose | ^6.1.3 | JWT/JWKS verification (Supabase) |
| dotenv | ^16.3.1 | Environment variables |
| cors | ^2.8.5 | CORS middleware |

### Frontend (Flutter)

| Package | Version | Purpose |
|---------|---------|---------|
| Flutter SDK | >=3.2.0 <4.0.0 | Framework |
| supabase_flutter | ^2.8.0 | Supabase auth & client |
| google_sign_in | ^6.2.1 | Google Sign-In |
| socket_io_client | ^3.1.4 | Socket.io client |
| provider | ^6.1.1 | State management |
| http | ^1.1.0 | HTTP client |
| shared_preferences | ^2.2.2 | Local storage |

### External Services

| Service | Purpose |
|---------|---------|
| MongoDB | Database |
| Supabase | Auth (Google OAuth), JWKS for JWT verification |
| Google Cloud Console | OAuth client (Web + Android/iOS) |

---

## Project Structure

```
Connect/
├── backend/
│   ├── config/
│   │   ├── constants.js
│   │   └── database.config.js
│   ├── controllers/
│   ├── database/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── socket/
│   ├── store/
│   ├── utils/
│   ├── .env.example
│   ├── package.json
│   └── server.js
├── frontend/
│   ├── assets/config/
│   │   └── app_config.json
│   └── lib/
│       ├── config/
│       ├── controllers/
│       ├── models/
│       ├── services/
│       ├── theme/
│       ├── utils/
│       └── views/
├── .gitignore
└── README.md
```

---

## Setup & Installation

### Prerequisites

- **Node.js** 18 or higher
- **Flutter** SDK 3.2+
- **MongoDB** (local or cloud)
- **Supabase** project
- **Google Cloud** project (for OAuth)

### 1. Clone the Repository

```bash
git clone https://github.com/mahmudul-hasan-exe/Connect.git
cd Connect
```

### 2. Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your values
```

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
# Create/edit assets/config/app_config.json (see Configuration)
```

---

## Configuration

### Backend `.env`

Create `backend/.env` from `.env.example`:

```env
PORT=3002
MONGODB_URI=mongodb://127.0.0.1:27017/connect
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
```

| Variable | Description |
|----------|-------------|
| PORT | API server port (default 3002) |
| MONGODB_URI | MongoDB connection string |
| SUPABASE_URL | Supabase project URL |

### Frontend `app_config.json`

Create or edit `frontend/assets/config/app_config.json` (copy from `app_config.example.json`):

```json
{
  "apiBaseUrl": "http://YOUR_BACKEND_IP:3002",
  "supabaseUrl": "https://YOUR_PROJECT.supabase.co",
  "supabaseAnonKey": "YOUR_SUPABASE_ANON_KEY",
  "googleWebClientId": "YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com",
  "port": 3002
}
```

| Key | Description |
|-----|-------------|
| apiBaseUrl | Backend API URL (use LAN IP for physical devices) |
| supabaseUrl | Supabase project URL |
| supabaseAnonKey | Supabase anonymous/public key |
| googleWebClientId | Google OAuth Web Client ID |

### Google Sign-In Setup

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sign-In API
3. Create OAuth 2.0 credentials:
   - **Web client** → use as `googleWebClientId`
   - **Android client** → add SHA-1 from `flutter run` or `keytool`
4. Add the Web client ID in Supabase Dashboard → Authentication → Providers → Google

---

## Running the Application

### Backend

**In-memory database (development):**

```bash
cd backend
npm run dev:mem
```

**Local MongoDB:**

```bash
cd backend
npm run dev:local
```

**Production-style:**

```bash
cd backend
npm start
```

Backend runs on `http://localhost:3002` (or configured PORT).

### Frontend

```bash
cd frontend
flutter run -d macos
# or: flutter run -d chrome
# or: flutter run -d <device-id>
```

For Android/iOS devices, set `apiBaseUrl` in `app_config.json` to your machine's LAN IP (e.g. `http://192.168.1.102:3002`).

---

## API Reference

Base URL: `http://localhost:3002/api` (or your configured URL)

### Health

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/verify` | Verify Supabase JWT and create/update user |

### Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/:id` | Get user by ID |
| PATCH | `/api/users/:id` | Update user (name, avatar) |

### Chats

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/chats` | List user's chats |
| POST | `/api/chats` | Create chat between two users |
| GET | `/api/chats/:id/messages` | Get messages for a chat |

### Messages

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/messages` | Send message (also via Socket.io) |
| PATCH | `/api/messages/:id/read` | Mark message as read |

### Connection Requests

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/connection-requests` | List sent/received requests |
| POST | `/api/connection-requests` | Send connection request |
| PATCH | `/api/connection-requests/:id/accept` | Accept request |
| PATCH | `/api/connection-requests/:id/reject` | Reject request |

### Blocks

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/blocks` | Block user |
| DELETE | `/api/blocks/:userId` | Unblock user |

### Socket.io Events

| Event | Direction | Description |
|-------|-----------|-------------|
| `auth` | Client → Server | Send `userId` after connection |
| `send_message` | Client → Server | `{ chatId, senderId, text }` |
| `message` | Server → Client | New message payload |
| `message_status` | Server → Client | Delivery status update |
| `typing` | Both | `{ chatId, userId, isTyping }` |
| `user_online` | Server → Client | `{ userId, online, lastSeen }` |

---

## Integration Guide

### Connect from a New Flutter App

1. Copy `lib/` structure and dependencies from `frontend/pubspec.yaml`
2. Use `assets/config/app_config.json` for API URL, Supabase, and Google config
3. Use `api_service.dart` for REST calls and `socket_service.dart` for real-time events

### Connect from a Web/React/Vue App

1. Backend is REST + Socket.io; any HTTP client and Socket.io client can connect
2. Auth: Obtain Supabase JWT via Google Sign-In, send in `Authorization: Bearer <token>`
3. Use Socket.io client to connect, emit `auth` with `userId` after JWT verification

### Connect from Mobile (Native)

1. Use Supabase SDK or REST for auth
2. Call `/api/auth/verify` with the Supabase access token
3. Use Socket.io client library to connect to backend WebSocket

---

## Contributing

Connect is open source. Anyone can use, modify, and contribute.

### How to Contribute & Upload Code

1. **Fork the repository:** Go to https://github.com/mahmudul-hasan-exe/Connect and click **Fork**

2. **Clone your fork:**
   ```bash
   git clone https://github.com/mahmudul-hasan-exe/Connect.git
   cd Connect
   ```

3. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature
   ```

4. **Make changes, test, then commit:**
   ```bash
   git add .
   git commit -m "Add: your feature description"
   ```

5. **Push to your fork and open a Pull Request:**
   ```bash
   git push -u origin feature/your-feature
   ```
   Go to https://github.com/mahmudul-hasan-exe/Connect/compare and create a Pull Request from your branch.

### Code Guidelines

- Use clear commit messages
- Keep the project structure consistent
- Do not commit `.env`, `app_config.json` with real keys, or other secrets
- Ensure `flutter analyze` passes and backend runs without errors

---

## Support

- **Repository:** https://github.com/mahmudul-hasan-exe/Connect
- **Issues:** https://github.com/mahmudul-hasan-exe/Connect/issues
