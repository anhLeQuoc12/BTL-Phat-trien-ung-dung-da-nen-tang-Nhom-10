const Food = require("../models/food");
const ObjectId = require("mongodb").ObjectId;

async function createFood(req, res) {
    const { name, unitsIds, categoryId, imageUrl } = req.body;

    try {
        const newFood = await Food.create({
            name: name,
            unitsIds: unitsIds,
            categoryId: categoryId,
            imageUrl: imageUrl
        });
        return res.status(201).json(newFood);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function getAllFoods(req, res) {
    try {
        const foods = await Food.find({}).exec();
        return res.status(200).json(foods);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function getFoodById(req, res) {
    const foodId = req.params.id;

    try {
        const food = await Food.findOne({
            _id: new ObjectId(foodId),
        }).populate("unitsIds categoryId").exec();
        if (food) {
            return res.status(200).json(food);
        } else {
            return res.status(400).json({ message: "Can't find food with ID supplied." });
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function updateFoodById(req, res) {
    const foodId = req.params.id;
    const { newName, newUnitsIds, newCategoryId, newImageUrl } = req.body;

    if (!newName && !newUnitsIds && !newCategoryId && !newImageUrl) {
        return res.json({ message: "Updating food needs at least 1 of 4 following information: newName, newUnitsIds, newCategoryId or newImageUrl." });
    }

    const updateObject = {};
    if (newName) {
        updateObject.name = newName;
    }
    if (newUnitsIds) {
        updateObject.unitsIds = newUnitsIds;
    }
    if (newCategoryId) {
        updateObject.categoryId = newCategoryId;
    }
    if (newImageUrl) {
        updateObject.imageUrl = newImageUrl;
    }

    try {
        const updatedfood = await Food.findOneAndUpdate({
            _id: new ObjectId(foodId),
        }, updateObject, { returnOriginal: false }).exec();
        if (updatedfood) {
            return res.status(200).json(updatedfood);
        } else {
            return res.status(400).json({ message: "Can't find food with ID supplied." });
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

async function deleteFoodById(req, res) {
    const foodId = req.params.id;

    try {
        const result = await Food.deleteOne({
            _id: new ObjectId(foodId),
        }).exec();
        if (result.deletedCount === 0) {
            return res.status(500).json({ message: "There has errors while deleting food with ID supplied."});
        } else {
            return res.status(200).json({ message: "Delete food successfully."});
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

module.exports = {
    createFood,
    getAllFoods,
    getFoodById,
    updateFoodById,
    deleteFoodById
}
