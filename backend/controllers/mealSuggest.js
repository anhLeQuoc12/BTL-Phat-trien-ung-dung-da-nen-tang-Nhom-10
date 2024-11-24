const Recipe = require('../models/recipe.model');

async function getSuggestMeal(req, res) {
    const ingredients = req.body.ingredients;
    try {
        const recipes = await Recipe.find({
            ingredients: {
                $elemMatch: {
                    $and: ingredients.map(ingredient => ({
                        foodId: ingredient.foodId,
                        quantity: { $lt: ingredient.quantity }
                    }))
                }
            }
        }).exec();
        res.status(200).json(recipes);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

module.exports = {
    getSuggestMeal
};