const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

const dbConfig = require('../config/database.config');

let memServer = null;

async function getMongoUri() {
  if (process.env.USE_IN_MEMORY_DB === '1') {
    if (!memServer) memServer = await MongoMemoryServer.create();
    return memServer.getUri();
  }
  return dbConfig.defaultUri;
}

let reconnectTimer = null;

function setupConnectionEvents() {
  mongoose.connection.on('error', () => {});

  mongoose.connection.on('disconnected', () => {
    if (reconnectTimer) clearTimeout(reconnectTimer);
    if (process.env.USE_IN_MEMORY_DB === '1') return;
    reconnectTimer = setTimeout(() => {
      mongoose.connect(dbConfig.defaultUri, dbConfig.options).catch(() => {});
    }, dbConfig.reconnectIntervalMs);
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
  const uri = await getMongoUri();

  for (let attempt = 1; attempt <= dbConfig.maxRetries; attempt++) {
    try {
      await mongoose.connect(uri, dbConfig.options);
      return;
    } catch (err) {
      if (attempt >= dbConfig.maxRetries) {
        console.error('MongoDB connection failed:', err.message);
        process.exit(1);
      }
      await new Promise((r) => setTimeout(r, dbConfig.retryDelayMs));
    }
  }
}

module.exports = { connectDB };
