# Connect

Real-time chat app with a Node.js/Express backend and Flutter frontend. Sign in with your name, send connection requests, then chat with real-time messaging, typing indicators, and block support.

**Quick start:** Install and run the backend (`cd backend && npm install && npm start`), set `MONGODB_URI` in `.env`, then run the frontend (`cd frontend && flutter pub get && flutter run`). Ensure MongoDB is running.

---

## Project structure

```
chatapp/
├── backend/     Node.js API + Socket.io
├── frontend/    Flutter app (Connect)
└── README.md
```

---

## Features

**Auth & onboarding** — Name-only sign-in; first-time onboarding; session persistence.

**Profile** — View/edit name and avatar; logout.

**Connections** — Send and accept connection requests; see connection status before starting a chat.

**Chats & messaging** — Chat list with last message and unread count; new chat with connected users; real-time send/receive via Socket.io; latest message pinned to bottom; sent/delivered status.

**Real-time** — Typing indicator; online status and last seen; live message and status updates.

**Block & privacy** — Block/Unblock from chat 3-dot menu; “You have blocked” / “You are blocked” banners; blocked sender’s new messages are not delivered.

**UX** — Notification screen for requests; unread and request badges; Connect branding on splash and login.

---

## Backend

Node.js, Express, MongoDB (Mongoose), Socket.io. Package: `connect-backend`.

**Setup**

```bash
cd backend
npm install
```

Create `.env` (see `.env.example`):

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/connect
```

**Run**

```bash
npm start
```

API base: `http://localhost:3000`

**API**

| Method | Route | Description |
|--------|--------|-------------|
| POST | `/api/auth` | Sign in (body: `name`, optional `avatar`) |
| GET | `/api/users` | List users |
| GET | `/api/chats/:userId` | List chats (`blockedByThem`, `iBlockedThem` per chat) |
| POST | `/api/chats` | Create chat (body: `userId`, `participantIds`) |
| GET | `/api/messages/:chatId` | Messages (query: `userId` for block flags, unread clear) |
| POST | `/api/connection-requests` | Send request (body: `fromUserId`, `toUserId`) |
| GET | `/api/connection-requests/received/:userId` | Received requests |
| PATCH | `/api/connection-requests/:id/accept` | Accept request |
| POST | `/api/blocks` | Block (body: `blockerId`, `blockedId`) |
| DELETE | `/api/blocks` | Unblock (body or query: `blockerId`, `blockedId`) |

**Socket**

- **Client → Server:** `auth(userId)`, `send_message(chatId, senderId, text)`, `typing(chatId, userId, isTyping)`
- **Server → Client:** `message`, `message_status`, `typing`, `user_online`

If the recipient has blocked the sender, new messages are not emitted to the recipient.

---

## Frontend

Flutter app **Connect** (`connect_chat`). Provider, `http`, `socket_io_client`.

**Setup**

```bash
cd frontend
flutter pub get
```

Set base URL in `lib/services/api_service.dart` (default `http://localhost:3000`). Use your machine’s LAN IP for a physical device.

**Run**

```bash
flutter run
```

Start the backend first so the app can reach the API and socket.

---

## Requirements

- **Backend:** Node.js, MongoDB (local or Atlas)
- **Frontend:** Flutter SDK; Android or iOS simulator or device
