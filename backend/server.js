require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const { connectDB } = require('./config/db');
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

app.use('/api', routes);
app.use(errorHandler);

app.set('io', io);
attachSocketHandler(io);

const PORT = process.env.PORT || 3000;

connectDB()
  .then(() => {
    server.listen(PORT);
  })
  .catch(() => {
    process.exit(1);
  });
