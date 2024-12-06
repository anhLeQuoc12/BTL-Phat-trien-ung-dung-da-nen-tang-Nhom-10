const _ = require("lodash");
const catchAsync = require("../utils/catchAsync");
const userGroupManagementService = require("../services/userGroupManagement.service");
const { throwBadRequest } = require("../utils/badRequestHandlingUtils");
const { roleMap } = require("../utils/roles");

const getUserGroupById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { userGroupId } = req.params;
  const userGroup = await userGroupManagementService.getUserGroupById(
    userGroupId
  );
  res.status(200).send(userGroup);
});

const createUserGroup = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const createBody = req.body;
  await userGroupManagementService.createUserGroup(createBody);
  res.status(201);
});

const updateUserGroupById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { userGroupId } = req.params;
  const updateBody = req.body;
  await userGroupManagementService.updateUserGroupById({
    updateBody,
    userGroupId,
  });
  res.status(200);
});

const deleteUserGroupById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { userGroupId } = req.params;
  await userGroupManagementService.deleteUserGroupById(userGroupId);
  res.status(200);
});

module.exports = {
  getUserGroupById,
  createUserGroup,
  updateUserGroupById,
  deleteUserGroupById,
};
