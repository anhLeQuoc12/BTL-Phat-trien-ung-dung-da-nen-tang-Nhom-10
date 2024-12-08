const express = require("express");
const dotenv = require("dotenv");
const cors= require("cors")
const groupRouter = require("./routes/group");
const listRoutes = require("./routes/list");

const app = express();
dotenv.config();
//midle
app.use(express.json());
app.use(cors());

app.use("/api/group", groupRouter);
app.use("/api/list", listRoutes);


const PORT = process.env.PORT || 8000;
app.listen(PORT, () => {
    console.log("Backend is running on port: " + PORT);
})
