const { Schema, model } = require("mongoose");

const recipeSchema = new Schema({
    userId: {
        type: ObjectId,
        ref: User,
        required: true
    },
    name: {
        type: String,
        required: true
    },
    ingredients: [{
        foodId: {
            type: ObjectId,
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
    createdAt: {
        type: Date,
        default: () => Date.now(),
        immutable: true
    },
    updatedAt: Date
})

const Recipe = model("Recipe", recipeSchema);
module.exports = Recipe;
