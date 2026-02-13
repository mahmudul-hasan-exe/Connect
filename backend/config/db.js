const mongoose = require('mongoose');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/connect';

const options = {
  maxPoolSize: 10,
  minPoolSize: 2,
  serverSelectionTimeoutMS: 10000,
  socketTimeoutMS: 45000,
  heartbeatFrequencyMS: 10000,
  retryWrites: true,
};

const RECONNECT_INTERVAL_MS = 5000;
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 2000;
let reconnectTimer = null;

function setupConnectionEvents() {
  mongoose.connection.on('error', () => {});

  mongoose.connection.on('disconnected', () => {
    if (reconnectTimer) clearTimeout(reconnectTimer);
    reconnectTimer = setTimeout(() => {
      mongoose.connect(MONGODB_URI, options).catch(() => {});
    }, RECONNECT_INTERVAL_MS);
  });

  mongoose.connection.on('reconnected', () => {
    if (reconnectTimer) {
      clearTimeout(reconnectTimer);
      reconnectTimer = null;
    }
  });
}

async function connectDB() {
  setupConnectionEvents();

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      await mongoose.connect(MONGODB_URI, options);
      return;
    } catch (_) {
      if (attempt < MAX_RETRIES) {
        await new Promise((r) => setTimeout(r, RETRY_DELAY_MS));
      } else {
        process.exit(1);
      }
    }
  }
}

module.exports = { connectDB };
