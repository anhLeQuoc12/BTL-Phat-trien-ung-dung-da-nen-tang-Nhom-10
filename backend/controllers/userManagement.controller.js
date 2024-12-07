const catchAsync = require("../utils/catchAsync");


const queryUser = catchAsync(async (req, res) => {
	const { query } = req.body;
	const users = await userManagementService.queryUser(query);
	res.status(200).send(users);
});

const getUserById = catchAsync(async (req, res) => {
	const { userId } = req.params;
	const user = await userManagementService.getUserById(userId);
	res.status(200).send(user);
});

const updateUserById = catchAsync(async (req, res) => {
	const { userId } = req.params;
	await userManagementService.updateUserById(userId);
	res.status(200);
});

const deleteUserById = catchAsync(async (req, res) => {
	const { userId } = req.params;
	await userManagementService.deleteUserById(userId);
	res.status(200);
});

module.exports = {
	createUser,
	queryUser,
	getUserById,
	updateUserById,
	deleteUserById,
	changePassword
};
