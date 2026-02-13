const express = require('express');
const blockController = require('../controllers/blockController');

const router = express.Router();

router.post('/', blockController.block);
router.delete('/', blockController.unblock);

module.exports = router;
