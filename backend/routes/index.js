const express = require('express');
const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const chatRoutes = require('./chatRoutes');
const messageRoutes = require('./messageRoutes');
const connectionRequestRoutes = require('./connectionRequestRoutes');
const blockRoutes = require('./blockRoutes');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/chats', chatRoutes);
router.use('/messages', messageRoutes);
router.use('/connection-requests', connectionRequestRoutes);
router.use('/blocks', blockRoutes);

module.exports = router;
