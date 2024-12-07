const catchAsync = require("../utils/catchAsync");
const userManagementService = require("../services/userManagement.service");

const createUser = catchAsync(async (req, res) => {
	try {
		const userData = req.body;
		const newUser = await userManagementService.createUser(userData);
		return res.status(201).json(newUser);
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
});

const changePassword = catchAsync(async (req, res) => {
	try {
		const data = req.body;
		const result = await userManagementService.changePassword(data);
		return res.status(200).json({ status: "076", result });
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
})

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
