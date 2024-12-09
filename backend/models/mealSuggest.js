const {Schema, model} = require('mongoose');
const Recipe = require('./recipe');

const mealSuggestionSchema = new Schema({
    userId: {
        type: ObjectId,
        ref: User,
        required: true
    },
    
})

const MealPlan = model('MealPlan', mealSuggestionSchema);
module.exports = MealPlan;