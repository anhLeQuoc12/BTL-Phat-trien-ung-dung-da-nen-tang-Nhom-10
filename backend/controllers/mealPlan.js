const MealPlan = require("../models/mealPlan");

async function createMealPlan(req, res) {
    const { userId, date, time, recipes } = req.body;
    try {
        const newMealPlan = await MealPlan.create({
            userId: userId,
            date: date,
            time: time,
            recipes: recipes
        });
        return res.status(201).json(newMealPlan);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

async function getAllMealPlansWithUserId(req, res) {
    const { userId } = res.locals.userId;
    try {
        const mealPlans = await MealPlan.find({
            userId: userId
        }).exec();
        res.status(200).json(mealPlans);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

async function getMealPlansWithUserIdAtTime(req, res) {
    const { userId } = res.locals.userId;
    const { time } = req.params;
    try {
        const mealPlans = await MealPlan.find({
            userId: userId,
            Time: time
        }).exec();
        res.status(200).json(mealPlans);
    }  catch (error){
        res.status(400).json({ error: error.message });
    }
}

async function getMealPlansWithUserIdAtDate(req, res) {
    const { userId } = res.locals.userId;
    const { date } = req.params;
    try {
        const mealPlans = await MealPlan.find({
            userId: userId,
            Date: date
        }).exec();
        res.status(200).json(mealPlans);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

async function updateMealPlan(req, res) {
    const { mealPlanId } = req.params.id;
    const { newDate, newTime, newRecipes } = req.body;
    try {
        const mealPlan = await MealPlan.findOne({
            _id: mealPlanId
        }).exec();
        if(!mealPlan) {
            return res.status(404).json({ error: "Meal Plan not found" });
        }
        if(newDate) mealPlan.date = newDate;
        if(newTime) mealPlan.time = newTime;
        if(newRecipes) mealPlan.recipes = newRecipes;
        await mealPlan.save();
        res.status(200).json(mealPlan);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

async function deleteMealPlan(req, res) {
    const { mealPlanId } = req.params.id;
    try {
        const mealPlan = await MealPlan.findOne({
            _id: mealPlanId
        }).exec();
        if(!mealPlan) {
            return res.status(404).json({ error: "Meal Plan not found" });
        }
        await mealPlan.remove();
        res.status(200).json(mealPlan);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

module.exports = {
    createMealPlan,
    getAllMealPlansWithUserId,
    getMealPlansWithUserIdAtDate,
    getMealPlansWithUserIdAtTime,
    updateMealPlan,
    deleteMealPlan
}