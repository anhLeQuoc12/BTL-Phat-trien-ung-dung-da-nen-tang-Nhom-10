const express = require("express");
const dotenv = require("dotenv");
const bodyParser = require("body-parser");
const recipeRoutes = require("./routes/recipe");
const mealPlanRoutes = require("./routes/mealPlan");
const mealSuggestRoutes = require("./routes/mealSuggest");
const weeklyShoppingReportRoutes = require("./routes/weekly-shopping-report");
const { default: mongoose } = require("mongoose");

const app = express();
dotenv.config();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

mongoose.connect(process.env.MONGODB_URL);

app.use("/api/recipe", recipeRoutes);
app.use("/api/report-by-weeks", weeklyShoppingReportRoutes)
app.use("/api/mealPlan", mealPlanRoutes);
app.use("/api/mealSuggest", mealSuggestRoutes);

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log("Backend is running on port: " + PORT);
})
