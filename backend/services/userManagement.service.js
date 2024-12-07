const { UserModel } = require("../models");
const { status } = require("../utils/constant");

const getUserById = async (userId) => {
  const userGroup = await UserModel.findById(userId);
  return userGroup;
};

const queryUser = async (query) => {
  const users = await UserModel.find(query);
  return users;
};

const updateUserById = async ({ userId, updateBody }) => {
  const updatedUser = await UserModel.findByIdAndUpdate(
    userId,
    { $set: updateBody },
    { new: true }
  );
  return updatedUser;
};

const deleteUserById = async (userId) => {
  await UserModel.findByIdAndUpdate(userId, {
    $set: { status: status.disabled },
  });
};

module.exports = {
	getUserById,
	queryUser,
	updateUserById,
	deleteUserById
};
