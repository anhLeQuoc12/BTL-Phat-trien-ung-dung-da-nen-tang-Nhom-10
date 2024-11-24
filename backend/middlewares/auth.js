const passport = require("passport");
const httpStatus = require("http-status");
const ApiError = require("../utils/ApiError");
const { roleMap } = require("../utils/roles");
const { UserModel } = require("../models");

// isCs = isCustomerSupport
const verifyCallback =
  (req, resolve, reject, requiredRights) => async (err, userId) => {
    try {
      if (err || !userId) {
        return reject(new ApiError(httpStatus.UNAUTHORIZED, "Unauthorized"));
      }
      // TODO: cache
      const user = await UserModel.findById(userId);
      req.user = user;

      if (user.role === roleMap.admin) {
        resolve();
      }

      // TODO: check rights
      if (requiredRights.length > 0) {
      }

      resolve();
    } catch (error) {
      reject(error);
    }
  };

const auth =
  (...requiredRights) =>
  async (req, res, next) => {
    return new Promise((resolve, reject) => {
      passport.authenticate(
        "jwt",
        { session: false },
        verifyCallback(req, resolve, reject, requiredRights)
      )(req, res, next);
    })
      .then(() => next())
      .catch((err) => next(err));
  };

module.exports = auth;
