const { getAllCategories } = require("../controllers/categoryManagement.controller");
const authMiddleware = require("../middlewares/auth");

const router = require("express").Router();

router.get("", authMiddleware, getAllCategories);

module.exports = router;
