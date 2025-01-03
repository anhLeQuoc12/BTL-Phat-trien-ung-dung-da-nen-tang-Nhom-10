const express = require('express');
const {getSuggestMeal} = require('../controllers/mealSuggest');

const router = express.Router();

router.get("/meal-suggestion", getSuggestMeal);

module.exports = router;