const { UserGroupModel } = require("../models");
const { status } = require("../utils/constant");

const getUserGroupById = async (userGroupId) => {
  const userGroup = await UserGroupModel.findById(userGroupId);
  return userGroup;
};

const createUserGroup = async (createBody) => {
  await UserGroupModel.create(createBody);
};

const updateUserGroupById = async ({ updateBody, userGroupId }) => {
  const updatedUserGroup = await UserGroupModel.findByIdAndUpdate(
    userGroupId,
    { $set: updateBody },
    { new: true }
  );
  return updatedUserGroup;
};

const deleteUserGroupById = async (userGroupId) => {
  await UserGroupModel.findByIdAndUpdate(userGroupId, {
    $set: { status: status.disabled },
  });
};

module.exports = {
  getUserGroupById,
  createUserGroup,
  updateUserGroupById,
  deleteUserGroupById,
};
