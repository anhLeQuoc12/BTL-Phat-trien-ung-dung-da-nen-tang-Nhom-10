const express = require('express');
const authMiddleware = require('../middlewares/auth');
const { addFood, updateFood, deleteFood, getFoodsByCategory, getAllCategories } = require('../controllers/food');
const {getAllUnits} = require("../services/unitManagement.service");

const router = express.Router();
// router.post('/', authMiddleware, addFood);
// router.put('/', authMiddleware, updateFood);
// router.delete('/', authMiddleware, deleteFood);
router.get('/category/:id', authMiddleware, getFoodsByCategory);
// router.get('/category', authMiddleware, getAllCategories);

module.exports = router;

