const mongoose = require('mongoose');
const { SchemaTypes } = require('mongoose');

//Item in fridge
const fridgeItemSchema = new mongoose.Schema({
	userId: {
		type: SchemaTypes.ObjectId,
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
		type: Date,
		required: true,
		validate: {
			validator: function (value) {
				return value > new Date(); // Validate that the date is in the future
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
		default: 0
	},
	usedAt: {
		type: Date,
		default: null
	}
},
	{
		timestamps: true
	}
);

//Fridge
const fridgeSchema = new mongoose.Schema({
	userId: {
		type: SchemaTypes.ObjectId,
		ref: "User",
		required: true
	},
	items: {
		type: [fridgeItemSchema], // Array of Fridge Items
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

