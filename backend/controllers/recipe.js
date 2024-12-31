const { Fridge } = require("../models/fridgeItem");
const Recipe = require("../models/recipe");
const ObjectId = require("mongodb").ObjectId;

async function createRecipe(req, res) {
    const { name, ingredients, content, description } = req.body;
    const userId = res.locals.userId;

    try {
        const alreadyExistedRecipe = await Recipe.findOne({
            userId: userId,
            name: name
        }).exec();

        if (alreadyExistedRecipe) {
            return res.status(400).json({ message: "Recipe with name " + name + " has already existed." });
        } else {
            const newRecipe = await Recipe.create({
                userId: userId,
                name: name,
                ingredients: ingredients,
                content: content,
                description: description,
            });
            return res.status(201).json(newRecipe);
        }
        
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
        }).populate({
            path: "ingredients.foodId",
            select: "name unitId",
            populate: {
                path: "unitId",
                select: "name"
            }
        }).exec();
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
        const alreadyExistedRecipe = await Recipe.findOne({
            userId: userId,
            name: newName
        }).exec();

        if (alreadyExistedRecipe) {
            return res.status(400).json({ message: "Recipe with name " + newName + " has already existed." });
        } else {
            const updatedRecipe = await Recipe.findOneAndUpdate({
                _id: new ObjectId(recipeId),
                userId: userId
            }, updateObject, { returnOriginal: false }).exec();
            if (updatedRecipe) {
                return res.status(200).json(updatedRecipe);
            } else {
                return res.status(400).json({ message: "Can't find recipe with ID supplied." });
            }    
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
        }).populate({
            path: "ingredients.foodId",
            select: "name unitId",
            populate: {
                path: "unitId",
                select: "name"
            }
        }).exec();
        const fridge = await Fridge.findOne({
            userId: userId
        }).exec();

        const ingredients = recipe.ingredients;
        const items = fridge.items;
        let result = [];
        for (const ingredient of ingredients) {
            for (const item of items) {

                if (item.food.name === ingredient.foodId.name) {
                    let isSufficient;
                    let message;
                    if (item.expirationDate <= Date.now()) {
                        isSufficient = false;
                        message = "Food is expired!";
                    } else {
                        if (item.quantity - item.usedQuantity >= ingredient.quantity) {
                            isSufficient = true;
                            message = "Food is sufficient.";
                        } else {
                            isSufficient = false;
                            message = "Food is insufficient."
                        }
                    }
                    result.push({
                        foodId: ingredient.foodId._id,
                        foodName: ingredient.foodId.name,
                        foodUnit: ingredient.foodId.unitId.name,
                        isSufficient: isSufficient,
                        message: message,
                        need: ingredient.quantity,
                        available: item.quantity - item.usedQuantity,
                    })
                }
            }
        }

        const dontHaveIngredients = ingredients.filter((ingredient) => {
            for (const res of result) {
                if (res.foodName === ingredient.foodId.name) {
                    return false;
                }
            }
            return true;
        })
        for (const ingredient of dontHaveIngredients) {
            result.push({
                foodId: ingredient.foodId._id,
                foodName: ingredient.foodId.name,
                foodUnit: ingredient.foodId.unitId.name,
                isSufficient: false,
                message: "Don't have food in fridge.",
                need: ingredient.quantity,
                available: 0,
            })
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
