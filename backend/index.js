const express = require("express");
const dotenv = require("dotenv");
const bodyParser = require("body-parser");
const recipeRoutes = require("./routes/recipe");
const weeklyShoppingReportRoutes = require("./routes/weekly-shopping-report");
const fridgeRoutes = require('./routes/fridge');
const { default: mongoose } = require("mongoose");

const app = express();
dotenv.config();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

mongoose.connect(process.env.MONGODB_URL);

app.use("/api/recipe", recipeRoutes);
app.use("/api/report-by-weeks", weeklyShoppingReportRoutes);
app.use("/api/fridge", fridgeRoutes);

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log("Backend is running on port: " + PORT);
})
