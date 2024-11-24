const express = require("express");
const dotenv = require("dotenv");
const recipeRoutes = require("./routes/recipe");
const mealPlanRoutes = require("./routes/mealPlan");
const mealSuggestRoutes = require("./routes/mealSuggest");

const app = express();
dotenv.config();

app.use("/api/recipe", recipeRoutes);
app.use("/api/mealPlan", mealPlanRoutes);
app.use("/api/mealSuggest", mealSuggestRoutes);

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log("Backend is running on port: " + PORT);
})
