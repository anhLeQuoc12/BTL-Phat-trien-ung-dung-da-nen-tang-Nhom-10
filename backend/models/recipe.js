const { Schema, model, SchemaTypes } = require("mongoose");
const User = require("./user.model");
const Food = require("./food");

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
    ingredients: [{
        foodId: {
            type: SchemaTypes.ObjectId,
            ref: Food,
            required: true
        },
        quantity: {
            type: Number,
            required: true
        }
    }],
    content: [String],
    description: [String],
}, { timestamps: true })

const Recipe = model("Recipe", recipeSchema);
module.exports = Recipe;
