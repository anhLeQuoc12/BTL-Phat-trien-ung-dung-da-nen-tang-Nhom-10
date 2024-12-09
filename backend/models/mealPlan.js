const {Schema, model} = require('mongoose');
const Recipe = require('./recipe');

const mealPlanSchema = new Schema({
    userId: {
        type: ObjectId,
        ref: User,
        required: true
    },
    Date: {
        type: Date,
        required: true
    },
    Time: {
        type: String,
        required: true
    },
    recipes: [{
        recipeId: {
            type: ObjectId,
            ref: Recipe,
        }
    }],
    createdAt : {
        type: Date,
        required: true
    },
    updateAt : {
        type: Date,
        required: true
    }
})

const MealPlan = model('MealPlan', mealPlanSchema);
module.exports = MealPlan;