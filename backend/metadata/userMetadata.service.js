const { UserModel } = require("../models");

const getUserForRequest = async (userId) => {
	// TODO: cache
  const userModel = await UserModel.findById(userId);
  return userModel.toJSON();
};

module.exports = {
  getUserForRequest,
};
