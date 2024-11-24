const express = require("express");
const dotenv = require("dotenv");
const recipeRoutes = require("./routes/recipe");
const mealPlanRoutes = require("./routes/mealPlan");

const app = express();
dotenv.config();

app.use("/api/recipe", recipeRoutes);
app.use("/api/mealPlan", mealPlanRoutes);

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log("Backend is running on port: " + PORT);
})
