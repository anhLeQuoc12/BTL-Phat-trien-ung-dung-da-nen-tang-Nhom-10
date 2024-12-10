const User = require("../models/user.model");

async function checkIsAdminOrNotMiddleware(req, res, next) {
    const userId = res.locals.userId;
    try {
        const requestedAccount = await User.findOne({
            _id: userId
        }, "role");
        if (requestedAccount.role !== "admin") {
            return res.status(403).json( { message: "Forbidden!" });
        } else {
            next();
        }
    } catch (error) {
        console.log(error)
        return res.status(500).json( {message: "There has errors while checking is admin or not!"} );
    }
}

module.exports = checkIsAdminOrNotMiddleware
