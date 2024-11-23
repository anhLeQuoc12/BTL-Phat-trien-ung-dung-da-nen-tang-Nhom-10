const express = require("express");
const { createRecipe, getAllRecipes, getRecipeById } = require("../controllers/recipe");

const router = express.Router();
router.post("", authMiddleware, createRecipe);
router.get("", authMiddleware, getAllRecipes);
router.get("/:id", authMiddleware, getRecipeById);

module.exports = router;
