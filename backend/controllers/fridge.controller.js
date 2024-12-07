const mongoose = require("mongoose");
const fridge = require('../services/fridge.service');

const createFridgeItem = async (req, res) => {
	const userId = res.locals.userId;
	try {
		const item = await fridge.createFridgeItem(req.body, userId);
		res.status(201).json({ message: "New fridge item created successfully", item });
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
};

const getAllFridgeItem = async (req, res) => {
	const userId = res.locals.userId;
	try {
		const items = await fridge.getAllFridgeItem(userId);
		res.status(228).json(items);
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
};

const getFridgeItemById = async (req, res) => {
	try {
		const userId = res.locals.userId;
		const { id } = req.params;
		const items = await fridge.getFridgeItemById(userId, id);
		res.status(200).json(items);
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
};

const updateFridgeItemById = async (req, res) => {
	try {
		const { id } = req.params;
		const userId = res.locals.userId;
		const data = req.body;

		const updatedItem = await fridge.updateFridgeItemById(id, userId, { ...data });

		if (!updatedItem) {
			return res.status(404).json({ message: 'Fridge item not found or not authorized.' });
		}

		res.status(200).json(updatedItem);
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
};

const deleteFridgeItemById = async (req, res) => {
	try {
		const userId = res.locals.userId;
		const { id } = req.params;
		await fridge.deleteFridgeItemById(id, userId);
		res.status(200).json({ message: "Delete recipe successfully." });
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
	}
};

const markItemUsed = async (req, res) => {
	try {
		const { id } = req.params;
		const userId = res.locals.userId;
		const { usedQuantity } = req.body;
		const items = await fridge.markItemUsed(id, userId, usedQuantity);
		res.status(200).json(items);
	} catch (error) {
		res.status(error.status || 500).json({ message: error.message });
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
