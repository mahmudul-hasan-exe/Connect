const mongoose = require('mongoose');
const Block = require('../models/Block');

async function isBlocked(blockerId, blockedId) {
  const exists = await Block.exists({
    blocker: new mongoose.Types.ObjectId(blockerId),
    blocked: new mongoose.Types.ObjectId(blockedId),
  });
  return !!exists;
}

async function block(req, res, next) {
  try {
    const { blockerId, blockedId } = req.body;
    if (!blockerId || !blockedId || blockerId === blockedId) {
      return res.status(400).json({ error: 'Invalid blockerId or blockedId' });
    }
    const blocker = new mongoose.Types.ObjectId(blockerId);
    const blocked = new mongoose.Types.ObjectId(blockedId);
    const existing = await Block.findOne({ blocker, blocked });
    if (!existing) await Block.create({ blocker, blocked });
    res.status(201).json({ blocked: true });
  } catch (err) {
    next(err);
  }
}

async function unblock(req, res, next) {
  try {
    const blockerId = req.body?.blockerId ?? req.query?.blockerId;
    const blockedId = req.body?.blockedId ?? req.query?.blockedId;
    if (!blockerId || !blockedId) {
      return res.status(400).json({ error: 'Invalid blockerId or blockedId' });
    }
    await Block.deleteOne({
      blocker: new mongoose.Types.ObjectId(blockerId),
      blocked: new mongoose.Types.ObjectId(blockedId),
    });
    res.json({ blocked: false });
  } catch (err) {
    next(err);
  }
}

module.exports = { block, unblock, isBlocked };
