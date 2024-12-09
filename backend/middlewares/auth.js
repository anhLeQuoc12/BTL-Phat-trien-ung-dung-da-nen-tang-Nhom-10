const jwt = require("jsonwebtoken");
const ObjectId = require("mongodb").ObjectId;

const authMiddleware = async (req, res, next) => {
    // const authorizationHeader = req.get('Authorization');
    // let token;
    // if (authorizationHeader) {
    //     token = authorizationHeader.split(" ")[1];
    // }

    // if (!token) {
    //     return res.status(401).json({ message: "No token included. User is not authenticated."});
    // } else {
    //     jwt.verify(token, process.env.JWT_SECRETKEY, (err, decoded) => {
    //         if (err) {
    //             return res.status(400).json({ message: "Token is expired or not true, and user is not authenticated."});
    //         }
    //         res.locals.userId = new ObjectId(decoded.id);
    //         next();
    //     })
    // }
    next();
}

module.exports = authMiddleware;
