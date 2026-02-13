const mongoose = require('mongoose');
const { Chat, User, Message, ConnectionRequest } = require('../models');
const { isOnline, getLastSeen } = require('../store/onlineUsers');
const { getUnread } = require('../store/unreadCount');
const { isBlocked } = require('./blockController');

function formatChatResponse(chat, other, lastMsg, userId, blockedByThem = false, iBlockedThem = false) {
  return {
    id: chat._id.toString(),
    participants: chat.participants.map((p) => p.toString()),
    createdAt: new Date(chat.createdAt).getTime(),
    blockedByThem,
    iBlockedThem,
    otherUser: other
      ? (() => {
          const id = other._id.toString();
          const online = isOnline(id);
          return {
            id,
            name: other.name,
            avatar: other.avatar,
            online,
            lastSeen: online ? null : getLastSeen(id),
          };
        })()
      : null,
    lastMessage: lastMsg
      ? {
          id: lastMsg._id.toString(),
          chatId: chat._id.toString(),
          senderId: lastMsg.sender.toString(),
          text: lastMsg.text,
          createdAt: new Date(lastMsg.createdAt).getTime(),
          status: lastMsg.status,
        }
      : null,
    unread: userId ? getUnread(chat._id.toString(), userId) : 0,
  };
}

async function getByUserId(req, res, next) {
  try {
    const userId = req.params.userId;
    const userObjId = new mongoose.Types.ObjectId(userId);
    const chats = await Chat.find({ participants: userObjId })
      .sort({ updatedAt: -1 })
      .lean();
    const result = [];
    for (const chat of chats) {
      const otherId = chat.participants.find((p) => p.toString() !== userId);
      const otherIdStr = otherId?.toString();
      const other = otherId ? await User.findById(otherId).lean() : null;
      const lastMsg = await Message.findOne({ chat: chat._id })
        .sort({ createdAt: -1 })
        .lean();
      const blockedByThem = otherIdStr ? await isBlocked(otherIdStr, userId) : false;
      const iBlockedThem = otherIdStr ? await isBlocked(userId, otherIdStr) : false;
      result.push(formatChatResponse(chat, other, lastMsg, userId, blockedByThem, iBlockedThem));
    }
    result.sort(
      (a, b) =>
        (b.lastMessage?.createdAt ?? b.createdAt) -
        (a.lastMessage?.createdAt ?? a.createdAt)
    );
    res.json(result);
  } catch (err) {
    next(err);
  }
}

async function create(req, res, next) {
  try {
    const { userId, participantIds } = req.body;
    if (!Array.isArray(participantIds) || participantIds.length !== 2) {
      return res.status(400).json({ error: 'Need exactly 2 participant ids' });
    }
    const otherUserId = participantIds.find((id) => id !== userId);
    if (!otherUserId) return res.status(400).json({ error: 'Invalid participants' });
    const u1 = new mongoose.Types.ObjectId(userId);
    const u2 = new mongoose.Types.ObjectId(otherUserId);
    const connected = await ConnectionRequest.findOne({
      $or: [
        { fromUser: u1, toUser: u2, status: 'accepted' },
        { fromUser: u2, toUser: u1, status: 'accepted' },
      ],
    });
    if (!connected) {
      return res.status(403).json({ error: 'Connect first. Send a request and wait for acceptance.' });
    }
    const sorted = [u1, u2].sort((a, b) => a.toString().localeCompare(b.toString()));
    let chat = await Chat.findOne({ participants: { $all: sorted } }).lean();
    if (!chat) {
      const created = await Chat.create({ participants: sorted });
      chat = created.toObject();
    }
    const otherId = chat.participants.find((p) => p.toString() !== userId);
    const otherIdStr = otherId?.toString();
    const other = otherId ? await User.findById(otherId).lean() : null;
    const blockedByThem = otherIdStr ? await isBlocked(otherIdStr, userId) : false;
    const iBlockedThem = otherIdStr ? await isBlocked(userId, otherIdStr) : false;
    res.status(201).json(formatChatResponse(chat, other, null, userId, blockedByThem, iBlockedThem));
  } catch (err) {
    next(err);
  }
}

module.exports = { getByUserId, create };
