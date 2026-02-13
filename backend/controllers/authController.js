const { User } = require('../models');

async function register(req, res, next) {
  try {
    const { name, avatar } = req.body;
    const user = await User.create({
      name: name || 'User',
      avatar: avatar || null,
    });
    const payload = {
      id: user._id.toString(),
      name: user.name,
      avatar: user.avatar,
      online: false,
    };
    res.status(201).json({
      user: payload,
      token: user._id.toString(),
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { register };
