const express = require("express");
const dotenv = require("dotenv");
const bodyParser = require("body-parser");
const adminRoutes = require("./routes/admin.route");
const recipeRoutes = require("./routes/recipe");
// const weeklyShoppingReportRoutes = require("./routes/weekly-shopping-report");
const { default: mongoose } = require("mongoose");

const app = express();
dotenv.config();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

mongoose.connect(process.env.MONGODB_URL)
.then(() => {
    console.log("Connecting database successfully.");
}).catch((error) => {
    console.log("Error in connecting to database:");
    console.log(error);
})

app.use("/admin", adminRoutes);
app.use("/api/recipe", recipeRoutes);
// app.use("/api/report-by-weeks", weeklyShoppingReportRoutes)

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log("Backend is running on port: " + PORT);
})
