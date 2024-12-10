const { Schema, model, SchemaTypes } = require("mongoose");
const User = require("./user.model");
const Food = require("./food");
const Unit = require("./unit.model");

const ingredientSchema = new Schema({
    foodId: {
        type: SchemaTypes.ObjectId,
        ref: Food,
        required: true
    },
    quantity: {
        type: Number,
        required: true
    }
}, {
    _id: false
})

const recipeSchema = new Schema({
    userId: {
        type: SchemaTypes.ObjectId,
        ref: User,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    ingredients: [ingredientSchema],
    content: [String],
    description: [String],
}, { timestamps: true })

const Recipe = model("Recipe", recipeSchema);
module.exports = Recipe;
