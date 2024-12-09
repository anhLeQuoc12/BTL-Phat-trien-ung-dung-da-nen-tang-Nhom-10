const { Schema, model, SchemaTypes } = require("mongoose");
const Unit = require("./unit.model");
const Category = require("./category.model");

const foodSchema = new Schema({
    name: {
        type: String,
        required: true
    },
    unitsIds: [{
        type: SchemaTypes.ObjectId,
        ref: Unit,
        required: true
    }],
    categoryId: {
        type: SchemaTypes.ObjectId,
        ref: Category,
        required: true
    },
    imageUrl: String
}, {
    timestamps: true
})

const Food = model("food", foodSchema);
module.exports = Food;
