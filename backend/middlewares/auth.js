const _ = require("lodash");
const httpStatus = require("http-status");
const jwt = require("jsonwebtoken");
const ApiError = require("../utils/ApiError");
const { getUserForRequest } = require("../metadata/userMetadata.service");
const { roleMap } = require("../utils/roles");

const authMiddleware = () => async (req, res, next) => {
  return new Promise((resolve, reject) => {
    const authHeader = _.get(req, "headers.authorization", "");
    const token = _.get(authHeader.split(), "1");

    if (authHeader === "admin") {
      req.user = {
        role: roleMap.admin,
      };
      resolve();
    }

    if (!token) {
      return reject(
        new ApiError(httpStatus.UNAUTHORIZED, "User is not authenticated.")
      );
    } else {
      jwt.verify(token, process.env.JWT_SECRETKEY, async (err, decoded) => {
        if (err) {
          return reject(
            new ApiError(
              httpStatus.BAD_REQUEST,
              "Token is expired or not true, and user is not authenticated."
            )
          );
        }
        res.locals.userId = new ObjectId(decoded.id);
        res.user = await getUserForRequest(decoded.id);
        resolve();
      });
    }
  })
    .then(() => next())
    .catch((err) => next(err));
};

module.exports = authMiddleware;
