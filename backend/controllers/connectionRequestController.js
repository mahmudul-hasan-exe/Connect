const mongoose = require('mongoose');
const { User, ConnectionRequest } = require('../models');
const { isOnline, getLastSeen, getSocketId } = require('../store/onlineUsers');

async function getStatus(userId, otherUserId) {
  const u1 = new mongoose.Types.ObjectId(userId);
  const u2 = new mongoose.Types.ObjectId(otherUserId);
  const sent = await ConnectionRequest.findOne({ fromUser: u1, toUser: u2 }).lean();
  if (sent) {
    if (sent.status === 'accepted') return 'connected';
    if (sent.status === 'pending') return 'pending_sent';
  }
  const received = await ConnectionRequest.findOne({ fromUser: u2, toUser: u1 }).lean();
  if (received) {
    if (received.status === 'accepted') return 'connected';
    if (received.status === 'pending') return 'pending_received';
  }
  return 'none';
}

async function send(req, res, next) {
  try {
    const { fromUserId, toUserId } = req.body;
    if (!fromUserId || !toUserId || fromUserId === toUserId) {
      return res.status(400).json({ error: 'Invalid fromUserId or toUserId' });
    }
    const from = new mongoose.Types.ObjectId(fromUserId);
    const to = new mongoose.Types.ObjectId(toUserId);
    const existing = await ConnectionRequest.findOne({
      $or: [
        { fromUser: from, toUser: to },
        { fromUser: to, toUser: from },
      ],
    }).lean();
    if (existing) {
      if (existing.status === 'accepted') {
        return res.status(400).json({ error: 'Already connected' });
      }
      if (existing.fromUser.toString() === fromUserId) {
        return res.status(400).json({ error: 'Request already sent' });
      }
      return res.status(400).json({ error: 'They already sent you a request' });
    }
    const doc = await ConnectionRequest.create({ fromUser: from, toUser: to, status: 'pending' });
    const fromUser = await User.findById(from).lean();
    const payload = {
      id: doc._id.toString(),
      fromUserId: fromUserId,
      fromUserName: fromUser?.name ?? 'User',
      fromUserAvatar: fromUser?.avatar ?? null,
      createdAt: new Date(doc.createdAt).getTime(),
    };
    const io = req.app.get('io');
    const toSocketId = getSocketId(toUserId);
    if (io && toSocketId) io.to(toSocketId).emit('friend_request', payload);
    res.status(201).json({
      ...payload,
      toUserId: toUserId,
      status: 'pending',
    });
  } catch (err) {
    next(err);
  }
}

async function getReceived(req, res, next) {
  try {
    const userId = req.params.userId;
    const list = await ConnectionRequest.find({
      toUser: new mongoose.Types.ObjectId(userId),
      status: 'pending',
    })
      .populate('fromUser', 'name avatar')
      .sort({ createdAt: -1 })
      .lean();
    const result = list.map((r) => ({
      id: r._id.toString(),
      fromUserId: r.fromUser._id.toString(),
      fromUserName: r.fromUser.name,
      fromUserAvatar: r.fromUser.avatar,
      status: r.status,
      createdAt: new Date(r.createdAt).getTime(),
    }));
    res.json(result);
  } catch (err) {
    next(err);
  }
}

async function accept(req, res, next) {
  try {
    const requestId = req.params.id;
    const doc = await ConnectionRequest.findById(requestId);
    if (!doc) return res.status(404).json({ error: 'Request not found' });
    if (doc.status !== 'pending') {
      return res.status(400).json({ error: 'Request already handled' });
    }
    doc.status = 'accepted';
    await doc.save();
    const acceptedByUser = await User.findById(doc.toUser).lean();
    const payload = {
      requestId: doc._id.toString(),
      acceptedByUserId: doc.toUser.toString(),
      acceptedByName: acceptedByUser?.name ?? 'User',
    };
    const io = req.app.get('io');
    const fromSocketId = getSocketId(doc.fromUser.toString());
    if (io && fromSocketId) io.to(fromSocketId).emit('friend_request_accepted', payload);
    res.json({
      id: doc._id.toString(),
      fromUserId: doc.fromUser.toString(),
      toUserId: doc.toUser.toString(),
      status: 'accepted',
    });
  } catch (err) {
    next(err);
  }
}

async function usersWithStatus(req, res, next) {
  try {
    const myUserId = req.params.userId;
    const users = await User.find().lean();
    const result = [];
    for (const u of users) {
      const id = u._id.toString();
      if (id === myUserId) continue;
      const status = await getStatus(myUserId, id);
      const isFriend = status === 'connected';
      result.push({
        id,
        name: u.name,
        avatar: u.avatar,
        online: isFriend ? isOnline(id) : false,
        lastSeen: isFriend ? (isOnline(id) ? null : getLastSeen(id)) : null,
        connectionStatus: status,
      });
    }
    res.json(result);
  } catch (err) {
    next(err);
  }
}

module.exports = { send, getReceived, accept, getStatus, usersWithStatus };
