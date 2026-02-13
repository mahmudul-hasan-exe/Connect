const onlineUsers = new Map();
const lastSeenMap = new Map();

function setOnline(userId, socketId) {
  onlineUsers.set(userId, { socketId });
  lastSeenMap.delete(userId);
}

function setOffline(userId) {
  const hadUserId = onlineUsers.has(userId);
  onlineUsers.delete(userId);
  return hadUserId;
}

function setLastSeen(userId, timestamp) {
  lastSeenMap.set(userId, timestamp);
}

function getLastSeen(userId) {
  return lastSeenMap.get(userId) ?? null;
}

function getSocketId(userId) {
  return onlineUsers.get(userId)?.socketId ?? null;
}

function isOnline(userId) {
  return onlineUsers.has(userId);
}

module.exports = {
  onlineUsers,
  lastSeenMap,
  setOnline,
  setOffline,
  setLastSeen,
  getLastSeen,
  getSocketId,
  isOnline,
};
