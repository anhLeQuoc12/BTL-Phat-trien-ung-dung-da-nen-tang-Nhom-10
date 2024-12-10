const {Schema, model, SchemaTypes} = require('mongoose');
const Recipe = require('./recipe');
const User = require('./user.model');

const mealPlanSchema = new Schema({
    userId: {
        type: SchemaTypes.ObjectId,
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
            type: SchemaTypes.ObjectId,
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