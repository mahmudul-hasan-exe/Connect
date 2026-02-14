# Connect

Real-time chat application with Google Sign-In. Node.js/Express + Socket.io backend, Flutter mobile frontend.

---

## Features

| Category | Description |
|----------|-------------|
| **Auth** | Google Sign-In (Supabase), onboarding, session persistence |
| **Profile** | Name, avatar, online/offline status, logout |
| **Connections** | Send/accept connection requests, status before chat |
| **Chat** | Chat list, unread count, real-time messaging, sent/delivered status |
| **Real-time** | Typing indicator, online status, last seen |
| **Privacy** | Block/unblock users, in-chat block banners |
| **UX** | Notification screen, unread and request badges |

---

## Project Structure

```
Connect/
├── backend/     Node.js API, MongoDB, Socket.io
│   ├── config/
│   ├── controllers/
│   ├── database/
│   ├── models/
│   ├── routes/
│   ├── socket/
│   └── server.js
├── frontend/    Flutter app (connect_app)
│   ├── assets/config/
│   └── lib/
│       ├── config/
│       ├── controllers/
│       ├── models/
│       ├── services/
│       ├── theme/
│       ├── utils/
│       └── views/
└── README.md
```

---

## Refactoring Log

- **Views:** `splash_screen` → `app_entry_view`; `chat_view` → `conversation_view`; `chats_view` → `inbox_view`; `new_chat_view` → `create_chat_view`; all views use `_view` suffix
- **Config:** Central config in `app_config.json`; Supabase + JWKS JWT verification
- **Backend:** Database connection refactored; removed debug code, Prettier config, ngrok
- **Code quality:** Flutter analyze clean; deprecated APIs updated
