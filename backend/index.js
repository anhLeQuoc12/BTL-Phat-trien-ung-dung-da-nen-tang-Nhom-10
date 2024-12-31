const express = require("express");
const dotenv = require("dotenv");
const bodyParser = require("body-parser");
const cors = require("cors"); // Import cors
const adminRoutes = require("./routes/admin.route");
const fridgeRoutes = require("./routes/fridge");
const userRoutes = require("./routes/user.route");
const auth = require("./routes/auth");
const recipeRoutes = require("./routes/recipe");
const mealPlanRoutes = require("./routes/mealPlan");
const mealSuggestRoutes = require("./routes/mealSuggest");
const listRoutes = require("./routes/list");
const workloadRoutes = require("./routes/workload");

// const weeklyShoppingReportRoutes = require("./routes/weekly-shopping-report");
const { default: mongoose } = require("mongoose");
// const cors = require('cors');

const app = express();
dotenv.config();

// Sử dụng CORS middleware trước các route khác
app.use(cors()); // Cấu hình CORS cho phép các request từ các domain khác

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

mongoose
  .connect(process.env.MONGODB_URL)
  .then(() => {
    console.log("Connecting database successfully.");
  })
  .catch((error) => {
    console.log("Error in connecting to database:");
    console.log(error);
  });

// Các route
app.use("/api/admin", adminRoutes);
app.use("/api/fridge", fridgeRoutes);
app.use("/api/user", userRoutes);
app.use("/api/recipe", recipeRoutes);
// app.use("/api/report-by-weeks", weeklyShoppingReportRoutes)
app.use("/api/mealPlan", mealPlanRoutes);
app.use("/api/mealSuggest", mealSuggestRoutes);
app.use("/api/list", listRoutes);
app.use("/api/workload", workloadRoutes);
app.use("/api/auth", auth);

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
  console.log("Backend is running on port: " + PORT);
});
