const { Chat, Message } = require('../models');
const {
  setOnline,
  setOffline,
  setLastSeen,
  getSocketId,
} = require('../store/onlineUsers');
const { incrementUnread } = require('../store/unreadCount');
const { isBlocked } = require('../controllers/blockController');

function attachSocketHandler(io) {
  io.on('connection', (socket) => {
    let currentUserId = null;
    const authTimeout = setTimeout(() => {
      if (currentUserId === null) {
        socket.disconnect(true);
      }
    }, 15000);

    socket.on('auth', (userId) => {
      clearTimeout(authTimeout);
      currentUserId = userId;
      setOnline(userId, socket.id);
      socket.broadcast.emit('user_online', {
        userId,
        online: true,
        lastSeen: null,
      });
    });

    socket.on('send_message', async (data) => {
      try {
        const { chatId, senderId, text } = data;
        const msg = await Message.create({
          chat: chatId,
          sender: senderId,
          text,
          status: 'sent',
        });
        const plain = msg.toObject ? msg.toObject() : msg;
        const payload = {
          id: plain._id.toString(),
          chatId: plain.chat.toString(),
          senderId: plain.sender.toString(),
          text: plain.text,
          createdAt: new Date(plain.createdAt).getTime(),
          status: plain.status || 'sent',
        };
        io.to(socket.id).emit('message', payload);
        const chat = await Chat.findById(chatId).lean();
        if (chat) {
          const otherId = chat.participants.find(
            (p) => p.toString() !== senderId
          );
          if (otherId) {
            const otherIdStr = otherId.toString();
            incrementUnread(chatId, otherIdStr);
            const recipientBlockedSender = await isBlocked(
              otherIdStr,
              senderId
            );
            const otherSocketId = getSocketId(otherIdStr);
            if (otherSocketId && !recipientBlockedSender) {
              io.to(otherSocketId).emit('message', {
                ...payload,
                status: 'delivered',
              });
              await Message.updateOne(
                { _id: msg._id },
                { status: 'delivered' }
              );
              io.to(socket.id).emit('message_status', {
                messageId: payload.id,
                status: 'delivered',
              });
            }
          }
        }
      } catch (_) {}
    });

    socket.on('typing', ({ chatId, userId, isTyping }) => {
      socket.broadcast.emit('typing', { chatId, userId, isTyping });
    });

    socket.on('disconnect', () => {
      clearTimeout(authTimeout);
      if (currentUserId) {
        const now = Date.now();
        setLastSeen(currentUserId, now);
        const hadUser = setOffline(currentUserId);
        if (hadUser) {
          socket.broadcast.emit('user_online', {
            userId: currentUserId,
            online: false,
            lastSeen: now,
          });
        }
      }
    });
  });
}

module.exports = { attachSocketHandler };
