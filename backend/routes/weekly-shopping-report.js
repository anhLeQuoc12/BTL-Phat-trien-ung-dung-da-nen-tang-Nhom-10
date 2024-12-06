const express = require("express");
const authMiddleware = require("../middlewares/auth");
const { getWeeklyReport } = require("../controllers/weekly-shopping-report");
const router = express.Router();

router.get("/", authMiddleware, getWeeklyReport);

module.exports = router;
