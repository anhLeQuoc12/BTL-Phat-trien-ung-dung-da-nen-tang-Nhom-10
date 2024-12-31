const express = require('express');
const authMiddleware = require('../middlewares/auth');
const { createUser, changePassword, changeUserInfo, getUserInfo } = require('../controllers/user.controller');

const router = express.Router();

router.post('', createUser);
router.get("", authMiddleware, getUserInfo);
router.put('/password', authMiddleware, changePassword);
router.put('/', authMiddleware, changeUserInfo);

module.exports = router;