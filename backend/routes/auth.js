const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const User = require('../models/user.model');
const jwt = require('jsonwebtoken');
const authMiddleware = require('../middlewares/auth');

router.post('/login', async (req, res) => {
    const { phone, password } = req.body;
    try {
        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(401).json({ message: 'Invalid users phone ' });
        }

        // const hashedPassword = user.password;
        // const isMatch = await bcrypt.compare(password, hashedPassword);
        const isMatch = user.password === password;

        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid password' });
        }
        
        const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRETKEY, { expiresIn: '60d' });
        res.status(200).json({ accountRole: user.role, token: token });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/logout', (req, res) => {
    res.status(200).json({ message: 'Logged out successfully' });
});

router.get("/", authMiddleware, async (req, res) => {
    const userId = res.locals.userId;
    try {
        const requestedAccount = await User.findOne({
            _id: userId
        }, "role");
        return res.status(200).json({ role: requestedAccount.role, message: "User is authenticated."});
    } catch (error) {
        console.log(error)
        return res.status(500).json( {message: "There has errors while retrieving user account's role!"} );
    }
})

module.exports = router;