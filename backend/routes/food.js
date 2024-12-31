const express = require("express");
const authMiddleware = require("../middlewares/auth");
const { getAllFoods, getFoodById } = require("../controllers/food");

const router = express.Router();
router.get("", authMiddleware, getAllFoods);
router.get("/:id", authMiddleware, getFoodById);

module.exports = router;
