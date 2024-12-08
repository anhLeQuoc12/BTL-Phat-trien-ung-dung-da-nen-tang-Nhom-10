const express = require("express");
const dotenv = require("dotenv");
const bodyParser = require("body-parser");
const adminRoute = require("./routes/admin.route");
const { default: mongoose } = require("mongoose");

const app = express();
dotenv.config();
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

mongoose.connect(process.env.MONGODB_URL);

app.use("/api/admin", adminRoute);

const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log("Backend is running on port: " + PORT);
})
