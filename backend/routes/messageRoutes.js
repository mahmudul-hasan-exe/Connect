const express = require('express');
const messageController = require('../controllers/messageController');

const router = express.Router();

router.get('/:chatId', messageController.getByChatId);

module.exports = router;
