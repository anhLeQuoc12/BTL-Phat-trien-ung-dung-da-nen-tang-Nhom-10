const Recipe = require("../models/recipe");
const ObjectId = require("mongodb").ObjectId;

async function createRecipe(req, res) {
    const { name, ingredients, content, description } = req.body;
    const userId = res.locals.userId;

    try {
        const newRecipe = await Recipe.create({
            userId: userId,
            name: name,
            ingredients: ingredients,
            content: content,
            description: description,
        });
        return res.status(201).json(newRecipe);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function getAllRecipes(req, res) {
    const userId = res.locals.userId;

    try {
        const recipes = await Recipe.find({
            userId: userId
        }, "name content").exec();
        return res.status(200).json(recipes);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function getRecipeById(req, res) {
    const recipeId = req.params.id;
    const userId = res.locals.userId;

    try {
        const recipe = await Recipe.findOne({
            _id: new ObjectId(recipeId),
            userId: userId
        }).populate("ingredients.foodId").exec();
        if (recipe) {
            return res.status(200).json(recipe);
        } else {
            return res.status(400).json({ message: "Can't find recipe with ID supplied." });
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function updateRecipeById(req, res) {
    const recipeId = req.params.id;
    const { newName, newIngredients, newContent, newDescription } = req.body;
    const userId = res.locals.userId;

    if (!newName && !newIngredients && !newContent && !newDescription) {
        return res.json({ message: "Updating recipe needs at least 1 of 4 following information: newName, newIngredients, newContent or newDescription" });
    }

    const updateObject = {};
    if (newName) {
        updateObject.name = newName;
    }
    if (newIngredients) {
        updateObject.ingredients = newIngredients;
    }
    if (newContent) {
        updateObject.content = newContent;
    }
    if (newDescription) {
        updateObject.description = newDescription;
    }

    try {
        const updatedRecipe = await Recipe.findOneAndUpdate({
            _id: new ObjectId(recipeId),
            userId: userId
        }, updateObject, { returnOriginal: false }).exec();
        if (updatedRecipe) {
            return res.status(200).json(updatedRecipe);
        } else {
            return res.status(400).json({ message: "Can't find recipe with ID supplied." });
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function deleteRecipeById(req, res) {
    const recipeId = req.params.id;
    const userId = res.locals.userId;

    try {
        const result = await Recipe.deleteOne({
            _id: new ObjectId(recipeId),
            userId: userId
        }).exec();
        if (result.deletedCount === 0) {
            return res.status(500).json({ message: "There has errors while deleting recipe with ID supplied."});
        } else {
            return res.status(200).json({ message: "Delete recipe successfully."});
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function connectRecipeWithFridge(req, res) {
    const recipeId = req.params.id;
    const userId = res.locals.userId;

    try {
        const recipe = await Recipe.findOne({
            _id: new ObjectId(recipeId),
            userId: userId
        }).populate("ingredients.food").exec();
        const fridge = await Fridge.findOne({
            userId: userId
        }).exec();

        const items = fridge.items;
        let result = [];
        for (const ingredient of recipe.ingredients) {
            for (const item of items) {

                if (item.food._id === ingredient.foodId._id) {
                    let isSufficient;
                    let message;
                    if (item.food.quantity >= ingredient.quantity) {
                        if (item.food.expirationDate >= Date.now()) {
                            isSufficient = false;
                            message = "Food is expired!"
                        } else {
                            isSufficient = true;
                            message = "Food is sufficient."
                        }
                    } else {
                        isSufficient = false;
                        message = "Food is insufficient."
                    }
                    result.push({
                        foodId: ingredient.foodId._id,
                        foodName: ingredient.foodId.name,
                        foodUnit: ingredient.foodId.unit,
                        isSufficient: isSufficient,
                        message: message,
                        available: item.food.quantity
                    })
                }
            }
        }

        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
}

module.exports = {
    createRecipe,
    getAllRecipes,
    getRecipeById,
    updateRecipeById,
    deleteRecipeById,
    connectRecipeWithFridge
}
