import Recipe from "../models/recipe";

async function createRecipe(req, res) {
    const { name, ingredients, content, description } = req.body;
    const { userId } = res.locals.userId;

    try {
        const newRecipe = await Recipe.create({
            userId: new ObjectId(userId),
            name: name,
            ingredients: ingredients,
            content: content,
            description: description,
        });
        return res.status(201).json(newRecipe);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

async function getAllRecipes(req, res) {
    const { userId } = res.locals.userId;

    try {
        const recipes = await Recipe.find({
            userId: new ObjectId(userId)
        }, "name content").exec();
        res.status(200).json(recipes);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

async function getRecipeById(req, res) {
    const recipeId = req.params.id;
    const { userId } = res.locals.userId;

    try {
        const recipe = await Recipe.findOne({
            _id: new ObjectId(recipeId),
            userId: new ObjectId(userId)
        }).exec();
        res.status(200).json(recipe);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

async function updateRecipe(req, res) {
    const { recipeId } = req.params.id;
    const { newName, newIngredients, newContent, newDescription } = req.body;

}

module.exports = {
    createRecipe,
    getAllRecipes,
    getRecipeById
}
