const Food = require("../models/food");
const ObjectId = require("mongodb").ObjectId;

async function createFood(req, res) {
    const { name, unitId, categoryId, imageUrl } = req.body;

    try {
        const alreadyExistedFood = await Food.findOne({
            name: name
        }).exec();

        if (alreadyExistedFood) {
            return res.status(400).json({ message: "Food with name " + name + " has already existed." });

        } else {
            const newFood = await Food.create({
                name: name,
                unitId: unitId,
                categoryId: categoryId,
                imageUrl: imageUrl
            });
            return res.status(201).json(newFood);
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}
async function getFoodsByCategory(req, res) {
    // const { categoryId } = req.body;
    const categoryId  = req.params.id;

    try {
        const foods = await Food.find({
            categoryId: categoryId
        })
            .populate("unitId", "name")
            .populate("categoryId", "name")
            .exec();
        return res.status(200).json(foods);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}
async function getAllFoods(req, res) {
    try {
        const foods = await Food.find({})
        .populate("unitId", "name")
        .populate("categoryId", "name")
        .exec();
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
        }).populate("unitId", "name")
        .populate("categoryId", "name")
        .exec();
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
    const { newName, newUnitId, newCategoryId, newImageUrl } = req.body;

    if (!newName && !newUnitId && !newCategoryId && !newImageUrl) {
        return res.json({ message: "Updating food needs at least 1 of 4 following information: newName, newUnitId, newCategoryId or newImageUrl." });
    }

    const updateObject = {};
    if (newName) {
        updateObject.name = newName;
    }
    if (newUnitId) {
        updateObject.unitId = newUnitId;
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
    getFoodsByCategory,
    createFood,
    getAllFoods,
    getFoodById,
    updateFoodById,
    deleteFoodById
}
