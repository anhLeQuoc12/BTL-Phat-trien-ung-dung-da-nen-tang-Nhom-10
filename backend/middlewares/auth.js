const jwt = require("jsonwebtoken")

const authMiddleware = async (req, res, next) => {
    const { token } = req.get('Authorization').split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: "User is not authenticated."});
    } else {
        jwt.verify(token, process.env.JWT_SECRETKEY, (err, decoded) => {
            if (err) {
                return res.status(400).json({ message: "Token is expired or not true, and user is not authenticated."});
            }
            res.locals.userId = new ObjectId(decoded.id);
        })
    }
}

module.exports = authMiddleware;
