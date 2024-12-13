const express = require('express');
const authMiddleware = require('../middlewares/auth');
const { createUser, changePassword, changeUserInfo } = require('../controllers/user.controller');

const router = express.Router();

router.post('', createUser);
router.put('/:id/password', authMiddleware, changePassword);
router.put('/:id', authMiddleware, changeUserInfo);

module.exports = router;