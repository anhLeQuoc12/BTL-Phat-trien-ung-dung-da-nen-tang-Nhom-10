const mongoose = require('mongoose');
const { SchemaTypes } = require('mongoose');

//Item in fridge
const fridgeItemSchema = new mongoose.Schema({
	itemId: {
		type: String,
		required: true,
		unique: true
	},
	userId: {
		type: ObjectId,
		ref: "User",
		required: true
	},
	food: {
		type: Object,
		ref: "Food",
		required: true
	},
	quantity: {
		type: Number,
		required: true
	},
	expirationDate: {
		type: String, // Date stored as string
		required: true,
		validate: {
			validator: function (value) {
				return new Date(value) > new Date(); // Validate that the date is in the future
			},
			message: 'Expiration date must be in the future.'
		}
	},
	storageLocation: {
		type: String,
		required: true
	},
	isUsed: {
		type: Boolean,
		required: true,
		default: false
	},
	usedQuantity: {
		type: Number,
		default: null
	},
	usedAt: {
		type: String,
		default: null
	}
},
	{
		timestamps: true
	}
);

//Fridge
const fridgeSchema = new mongoose.Schema({
	fridgeId: {
		type: String,
		required: true,
		unique: true
	},
	userId: {
		type: SchemaTypes.ObjectId,
		ref: "User",
		required: true
	},
	items: {
		type: [FridgeItem], // Array of Fridge Items
		required: true,
		default: []
	}},
	{
		timestamps: true
	}
);

const FridgeItem = mongoose.model('FridgeItem', fridgeItemSchema);
const Fridge = mongoose.model("Fridge", fridgeSchema);

module.exports = { FridgeItem, Fridge };
