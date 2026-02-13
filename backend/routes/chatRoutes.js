const express = require('express');
const chatController = require('../controllers/chatController');

const router = express.Router();

router.get('/:userId', chatController.getByUserId);
router.post('/', chatController.create);

module.exports = router;
