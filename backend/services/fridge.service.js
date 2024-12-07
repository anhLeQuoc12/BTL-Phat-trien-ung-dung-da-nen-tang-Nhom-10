const mongoose = require("mongoose");
const { FridgeItem, Fridge } = require('../models/fridgeItem');

const createFridgeItem = async (data, userId) => {
	const { food, quantity, expirationDate, storageLocation } = data;

	const newFridgeItem = await FridgeItem.create({
		userId: userId,
		food: food,
		quantity: quantity,
		expirationDate: expirationDate,
		storageLocation: storageLocation
	});

	return newFridgeItem;
};

const getAllFridgeItem = async (userId) => {
	const fridgeItems = await Fridge.find({
		userId: userId
	}).exec();

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
	try {
		
		const updatedFridgeItem = await FridgeItem.findOneAndUpdate({ 
			_id: new ObjectId(id),
			userId: userId  
		}, updates).exec();
	
		if (!updatedFridgeItem) {
		    return null;
		}
	
		return updatedFridgeItem;
	    } catch (error) {
		throw new Error(`Error updating fridge item: ${error.message}`);
	    }
 };

const deleteFridgeItemById = async (id, userId) => {
	try {
		const result = await FridgeItem.deleteOne({
			_id: new ObjectId(id),
			userId: userId
		}).exec();

		if(!result){
			return null;
		}

		return result;
	} catch (error) {
		throw new Error(`Error updating fridge item: ${error.message}`);
	}
 };

const markItemUsed = async (id, userId, usedQuantity) => {
	try {
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
		fridgeItem.usedQuantity = usedQuantity; 
		fridgeItem.usedAt = new Date().toISOString(); 
		fridgeItem.isUsed = fridgeItem.quantity === 0; 
	
		
		const updatedFridgeItem = await fridgeItem.save();
	
		return updatedFridgeItem; 
	} catch (error) {
		throw new Error(`Error updating fridge item: ${error.message}`);
	}
}

module.exports = {
	getAllFridgeItem,
	getFridgeItemById,
	createFridgeItem,
	updateFridgeItemById,
	deleteFridgeItemById,
	markItemUsed
};
