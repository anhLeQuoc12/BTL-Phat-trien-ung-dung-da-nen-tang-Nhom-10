const express = require('express');
const { createMealPlan, getAllMealPlansWithUserId, getMealPlansWithUserIdAtTime, getMealPlansWithUserIdAtDate, updateMealPlan, deleteMealPlan} = require('../controllers/mealPlan');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

router.post("", authMiddleware, createMealPlan);
router.get("/:id", authMiddleware, getAllMealPlansWithUserId);
router.get("/:id/:time", authMiddleware, getMealPlansWithUserIdAtTime);
router.get("/:id/:date", authMiddleware, getMealPlansWithUserIdAtDate);
router.patch("/:id", authMiddleware, updateMealPlan);
router.delete("/:id", authMiddleware, deleteMealPlan);

module.exports = router;
