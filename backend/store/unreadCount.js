const unreadMap = new Map();

function key(chatId, userId) {
  return `${String(chatId)}_${String(userId)}`;
}

function getUnread(chatId, userId) {
  return unreadMap.get(key(chatId, userId)) || 0;
}

function incrementUnread(chatId, userId) {
  const k = key(chatId, userId);
  unreadMap.set(k, (unreadMap.get(k) || 0) + 1);
}

function clearUnread(chatId, userId) {
  unreadMap.delete(key(chatId, userId));
}

module.exports = {
  getUnread,
  incrementUnread,
  clearUnread,
};
