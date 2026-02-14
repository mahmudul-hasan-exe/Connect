const { User } = require('../models');
const {
  verifySupabaseToken,
  isJwtVerificationError,
} = require('../utils/supabaseJwt');

function extractUserName(payload) {
  const meta = payload.user_metadata || {};
  return (
    meta.full_name ||
    meta.name ||
    (payload.email || '').split('@')[0] ||
    'User'
  );
}

function extractAvatar(payload) {
  const meta = payload.user_metadata || {};
  return meta.avatar_url || meta.picture || null;
}

async function verifySupabase(req, res, next) {
  try {
    const { accessToken } = req.body;
    if (!accessToken) {
      return res.status(400).json({ error: 'Access token required' });
    }

    const payload = await verifySupabaseToken(accessToken);
    const supabaseId = payload.sub;
    const name = extractUserName(payload);
    const avatar = extractAvatar(payload);

    let user = await User.findOne({ supabaseId });
    if (!user) {
      user = await User.create({ supabaseId, name, avatar });
    } else if (user.name !== name || user.avatar !== avatar) {
      user.name = name;
      user.avatar = avatar;
      await user.save();
    }

    return res.status(200).json({
      user: {
        id: user._id.toString(),
        name: user.name,
        avatar: user.avatar,
        online: false,
      },
      token: user._id.toString(),
    });
  } catch (err) {
    if (isJwtVerificationError(err)) {
      return res.status(401).json({ error: 'Invalid or expired token' });
    }
    next(err);
  }
}

module.exports = { verifySupabase };
