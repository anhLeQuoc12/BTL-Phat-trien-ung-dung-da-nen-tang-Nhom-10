const mongoose = require("mongoose");
const { User } = require("../models/user.model");

const createUser = async (userData) => {
	try {
		const { email, phone, password } = userData;
		
		const existingUser = await User.findOne({
			$or: [{ email }, { phone }],
		}).exec();

		if (existingUser) {
			throw new Error('Email or phone number already exists');
		}

		const hashedPassword = await bcrypt.hash(password, 10);

		const newUser = await new User.create({
			...userData,
			password: hashedPassword,
		});
		await newUser.save();

		return newUser;
	} catch (error) {
		throw new Error(`Error creating new user: ${error.message}`);
	}

}

const changePassword = async (data) => {
	try {
		const { userId, oldPassword, newPassword} = data;
	
		const user = await User.findById(userId).exec();
		if (!user) {
		    throw { status: 404, message: "User not found" };
		}
	
		// Check if old password matches
		const isPasswordValid = await bcrypt.compare(oldPassword, user.password);
		if (!isPasswordValid) {
		    throw { status: 400, message: "Old password is incorrect" };
		}
	
		const hashedNewPassword = await bcrypt.hash(newPassword, 10);
	
		user.password = hashedNewPassword;
		await user.save();

		return {
			resultMessage: "Password changed successfully"
		};
	
	    } catch (error) {
		throw new Error(`Error changing password: ${error.message}`);
	    }
}

module.exports = {
	createUser,
	changePassword
};
