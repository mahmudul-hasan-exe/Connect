const express = require('express');
const connectionRequestController = require('../controllers/connectionRequestController');

const router = express.Router();

router.get(
  '/users-with-status/:userId',
  connectionRequestController.usersWithStatus
);
router.post('/', connectionRequestController.send);
router.get('/received/:userId', connectionRequestController.getReceived);
router.patch('/:id/accept', connectionRequestController.accept);

module.exports = router;
