const mongoose = require('mongoose');
const { Message, Chat } = require('../models');
const { clearUnread } = require('../store/unreadCount');
const { getSocketId } = require('../store/onlineUsers');
const { isBlocked } = require('./blockController');

function formatMessageResponse(m) {
  return {
    id: m._id.toString(),
    chatId: m.chat.toString(),
    senderId: m.sender.toString(),
    text: m.text,
    createdAt: new Date(m.createdAt).getTime(),
    status: m.status,
  };
}

async function getByChatId(req, res, next) {
  try {
    const { chatId } = req.params;
    const userId = req.query.userId;
    if (userId) {
      clearUnread(chatId, userId);
      const userObjId = new mongoose.Types.ObjectId(userId);
      const chatObjId = new mongoose.Types.ObjectId(chatId);
      await Message.updateMany(
        { chat: chatObjId, sender: { $ne: userObjId } },
        { status: 'read' }
      );
      const updated = await Message.find({ chat: chatObjId, sender: { $ne: userObjId } })
        .select('_id sender')
        .lean();
      const io = req.app.get('io');
      const bySender = {};
      updated.forEach((m) => {
        const sid = m.sender.toString();
        if (!bySender[sid]) bySender[sid] = [];
        bySender[sid].push(m._id.toString());
      });
      Object.keys(bySender).forEach((senderId) => {
        const socketId = getSocketId(senderId);
        if (socketId) {
          io.to(socketId).emit('message_status', {
            messageIds: bySender[senderId],
            status: 'read',
          });
        }
      });
    }
    const list = await Message.find({ chat: new mongoose.Types.ObjectId(chatId) })
      .sort({ createdAt: 1 })
      .lean();
    const result = list.map(formatMessageResponse);
    if (userId) {
      const chatDoc = await Chat.findById(chatId).lean();
      const otherId = chatDoc?.participants?.find((p) => p.toString() !== userId)?.toString();
      const blockedByThem = otherId ? await isBlocked(otherId, userId) : false;
      const iBlockedThem = otherId ? await isBlocked(userId, otherId) : false;
      return res.json({ messages: result, blockedByThem, iBlockedThem });
    }
    res.json(result);
  } catch (err) {
    next(err);
  }
}

module.exports = { getByChatId, formatMessageResponse };
