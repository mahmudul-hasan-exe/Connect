module.exports = {
  defaultUri: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/connect',
  options: {
    maxPoolSize: 10,
    minPoolSize: 2,
    serverSelectionTimeoutMS: 10000,
    socketTimeoutMS: 45000,
    heartbeatFrequencyMS: 10000,
    retryWrites: true,
  },
  reconnectIntervalMs: 5000,
  maxRetries: 3,
  retryDelayMs: 2000,
};
