const _ = require("lodash");
const catchAsync = require("../utils/catchAsync");
const userManagementService = require("../services/userManagement.service");
const { throwBadRequest } = require("../utils/badRequestHandlingUtils");
const { roleMap } = require("../utils/roles");

const queryUser = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { query } = req.body;
  const users = await userManagementService.queryUser(query);
  res.status(200).send(users);
});

const getUserById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { userId } = req.params;
  const user = await userManagementService.getUserById(userId);
  res.status(200).send(user);
});

const updateUserById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { userId } = req.params;
  const updateBody = req.body;
  await userManagementService.updateUserById({ userId, updateBody });
  res.status(200);
});

const deleteUserById = catchAsync(async (req, res) => {
  throwBadRequest(_.get(req, "user.role") !== roleMap.admin, "Forbidden!");
  const { userId } = req.params;
  await userManagementService.deleteUserById(userId);
  res.status(200);
});

module.exports = {
	queryUser,
	getUserById,
	updateUserById,
	deleteUserById
};
