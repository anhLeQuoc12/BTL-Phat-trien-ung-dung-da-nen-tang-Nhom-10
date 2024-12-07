const mongoose = require("mongoose");
const userManagementService = require("../services/userManagement.service");

async function changeUserInfo(req, res) {
    const { newPhone, newEmail } = req.body;
    const userId = res.locals.userId;

    try {
        const updateObject = {};
        if (newPhone) {
            updateObject.newPhone = newPhone;
        }
        if (newEmail) {
            updateObject.newEmail = newEmail;
        }
        const user = await User.findOneAndUpdate({
            _id: userId
        }, updateObject).exec();
        return res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

const createUser = async (req, res) => {
	try {
		const userData = req.body;
		const newUser = await userManagementService.createUser(userData);
		return res.status(201).json(newUser);
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
};

const changePassword = async (req, res) => {
	try {
		const data = req.body;
		const result = await userManagementService.changePassword(data);
		return res.status(200).json({ status: "076", result });
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
};

module.exports = {
	createUser,
	changePassword
};