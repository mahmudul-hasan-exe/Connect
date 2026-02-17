require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const { connectDB } = require('./database/connection');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorHandler');
const { attachSocketHandler } = require('./socket/socketHandler');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' },
  pingTimeout: 5000,
  pingInterval: 3000,
  connectTimeout: 20000,
});

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ status: 'success', message: 'Connect API is running', health: '/api/health' });
});

app.use('/api', routes);
app.use(errorHandler);

app.set('io', io);
attachSocketHandler(io);

const { PORT } = require('./config/constants');

connectDB()
  .then(() => {
    server.listen(PORT, () => {
    });
  })
  .catch((err) => {
    console.error('Failed to start server:', err.message);
    process.exit(1);
  });
