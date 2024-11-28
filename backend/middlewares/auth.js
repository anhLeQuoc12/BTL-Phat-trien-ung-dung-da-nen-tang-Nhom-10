const jwt = require("jsonwebtoken")

const authMiddleware = (req, res, next) => {
    const { token } = req.header.Authorization.split(' ')[1];

    if (!token) {
        res.status(403).json({ message: "User is not authenticated."});
    } else {
        
    }
}
