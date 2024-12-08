const express = require('express');
const router = express.Router();

const User = require('../models/user.model');
const jwt = require('jsonwebtoken');

router.post('/login', async (req, res) => {
    const { phone , password } = req.body;
    try {
        const user = await User.findOne({ phone });
        if (!user ) {
            return res.status(401).json({ message: 'Invalid users phone ' });
        }
        if (user.password !== password) {
            return res.status(401).json({ message: 'Invalid password' });
        }
        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRETKEY, { expiresIn: '1h' });
        res.status(200).json({ token });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/logout', (req, res) => {
    res.status(200).json({ message: 'Logged out successfully' });
});

module.exports = router;