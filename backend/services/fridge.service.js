const mongoose = require("mongoose");
const ObjectId = require("mongodb").ObjectId;
const { FridgeItem, Fridge } = require('../models/fridgeItem');

const createFridge = async (userId) => {
	try {
		const newFridge = await Fridge.create({ userId: userId });
	} catch (error) {
		throw new Error(`Error creating new fridge: ${error.message}`);
	}
}

const createFridgeItem = async (data, userId) => {
	const { food, quantity, expirationDate, storageLocation } = data;

	// Tạo transaction để đảm bảo đồng bộ
	const session = await mongoose.startSession();
	session.startTransaction();

	try {
		if (!food || !quantity || !expirationDate || !storageLocation) {
			throw new Error('Missing required fields: food, quantity, expirationDate, storageLocation');
		}

		//tạo item mới
		const newFridgeItem = await FridgeItem.create([{
			userId: userId,
			food: food,
			quantity: quantity,
			expirationDate: expirationDate,
			storageLocation: storageLocation
		}], { session });

		//thêm item vào Fridge của user
		const fridge = await Fridge.findOne({ userId }).session(session).exec();

		if (!fridge) {
			throw new Error('Fridge not found for the user');
		}

		fridge.items.push(newFridgeItem[0]);
		await fridge.save({ session });

		// Commit transaction
		await session.commitTransaction();
		session.endSession();

		return newFridgeItem;
	} catch (error) {
		// Rollback transaction nếu có lỗi
		await session.abortTransaction();
		session.endSession();
		throw new Error(`Error creating fridge item: ${error.message}`);
	}

};

const getAllFridgeItem = async (userId) => {
	const fridgeItems = await Fridge.findOne({ userId: userId }, "items").exec();

	return fridgeItems;
};

const getFridgeItemById = async (userId, itemId) => {
	try {
		const fridgeItem = await FridgeItem.findOne({
			_id: new ObjectId(itemId),
			userId: userId
		}).exec();


		if (!fridgeItem) {
			throw new Error('Fridge item not found');
		}
		return fridgeItem;
	} catch (error) {
		throw new Error(`Error fetching fridge item: ${error.message}`);
	}
};

const updateFridgeItemById = async (id, userId, updates) => {
	// Tạo transaction để đảm bảo đồng bộ
	const session = await mongoose.startSession();
	session.startTransaction();

	try {

		const updatedFridgeItem = await FridgeItem.findOneAndUpdate({
			_id: new ObjectId(id),
			userId: userId
		}, updates, { new: true, session }).exec();

		if (!updatedFridgeItem) {
			throw new Error('Fridge item not found');
		}

		// Đồng bộ trong mảng items của Fridges
		const fridge = await Fridge.findOne({ userId }).session(session).exec();
		if (!fridge) {
			throw new Error('Fridge not found');
		}

		const itemIndex = fridge.items.findIndex(item => item._id.toString() === id);
		if (itemIndex === -1) {
			throw new Error('Fridge item not found in fridge collection');
		}

		fridge.items[itemIndex] = updatedFridgeItem;
		await fridge.save({ session });

		// Commit transaction
		await session.commitTransaction();
		session.endSession();

		return updatedFridgeItem;
	} catch (error) {
		await session.abortTransaction();
		session.endSession();
		throw new Error(`Error updating fridge item: ${error.message}`);
	}
};

const deleteFridgeItemById = async (id, userId) => {
	// Tạo transaction để đảm bảo đồng bộ
	const session = await mongoose.startSession();
	session.startTransaction();

	try {
		const result = await FridgeItem.deleteOne({
			_id: new ObjectId(id),
			userId: userId
		}, { session }).exec();

		if (result.deletedCount === 0) {
			throw new Error('Fridge item not found');
		}

		// Xóa item khỏi mảng items trong Fridges
		const fridge = await Fridge.findOne({ userId }).session(session).exec();
		if (!fridge) {
			throw new Error('Fridge not found');
		}

		fridge.items = fridge.items.filter(item => item._id.toString() !== id);
		await fridge.save({ session });

		// Commit transaction
		await session.commitTransaction();
		session.endSession();

		return result;
	} catch (error) {
		await session.abortTransaction();
		session.endSession();
		throw new Error(`Error deleting fridge item: ${error.message}`);
	}
};

const markItemUsed = async (id, userId, usedQuantity) => {
	try {
		if (!ObjectId.isValid(id)) {
			throw new Error('Invalid ObjectId');
		}
		
		const fridgeItem = await FridgeItem.findOne({
			_id: new ObjectId(id),
			userId: userId
		}).exec();

		if (!fridgeItem) {
			throw new Error('Fridge item not found or not authorized');
		}

		if (usedQuantity > fridgeItem.quantity) {
			throw new Error('Used quantity cannot exceed available quantity');
		}

		fridgeItem.quantity -= usedQuantity;
		fridgeItem.usedQuantity += Number(usedQuantity);
		fridgeItem.usedAt = new Date().toISOString();
		fridgeItem.isUsed = fridgeItem.quantity === 0;

		// Lưu lại FridgeItem
		const updatedFridgeItem = await fridgeItem.save();

		// Cập nhật mảng items của Fridge
		const fridge = await Fridge.findOne({ userId: userId }).exec();

		if (fridge) {
			fridge.items = fridge.items.map(item => {
				if (item._id.equals(updatedFridgeItem._id)) {
					return updatedFridgeItem;
				}
				return item;
			});

			await fridge.save();
		}

		return updatedFridgeItem;
	} catch (error) {
		throw new Error(`Error marking fridge item: ${error.message}`);
	}
}

module.exports = {
	getAllFridgeItem,
	getFridgeItemById,
	createFridgeItem,
	updateFridgeItemById,
	deleteFridgeItemById,
	markItemUsed,
	createFridge
};
