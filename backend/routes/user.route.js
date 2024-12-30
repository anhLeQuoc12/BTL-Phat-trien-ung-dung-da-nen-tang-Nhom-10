const express = require('express');
const authMiddleware = require('../middlewares/auth');
const { createUser, changePassword, changeUserInfo } = require('../controllers/user.controller');

const router = express.Router();

router.post('', createUser);
router.put('/password', authMiddleware, changePassword);
router.put('/', authMiddleware, changeUserInfo);

module.exports = router;