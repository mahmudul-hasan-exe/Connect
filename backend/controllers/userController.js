const { User } = require('../models');
const { isOnline, getLastSeen } = require('../store/onlineUsers');

async function getAll(req, res, next) {
  try {
    const list = await User.find().lean();
    const result = list.map((u) => {
      const id = u._id.toString();
      const online = isOnline(id);
      return {
        id,
        name: u.name,
        avatar: u.avatar,
        online,
        lastSeen: online ? null : getLastSeen(id),
      };
    });
    res.json(result);
  } catch (err) {
    next(err);
  }
}

module.exports = { getAll };
