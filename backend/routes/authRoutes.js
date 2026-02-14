const express = require('express');
const authController = require('../controllers/authController');

const router = express.Router();

router.post('/supabase', authController.verifySupabase);

module.exports = router;
