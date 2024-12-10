const express = require("express");
const { createRecipe, getAllRecipes, getRecipeById, updateRecipeById, deleteRecipeById, connectRecipeWithFridge } = require("../controllers/recipe");
const authMiddleware = require("../middlewares/auth");

const router = express.Router();
router.post("", authMiddleware, createRecipe);
router.get("", authMiddleware, getAllRecipes);
router.get("/:id", authMiddleware, getRecipeById);
router.put("/:id", authMiddleware, updateRecipeById);
router.delete("/:id", authMiddleware, deleteRecipeById);
// router.post("/:id", authMiddleware, connectRecipeWithFridge);

module.exports = router;
