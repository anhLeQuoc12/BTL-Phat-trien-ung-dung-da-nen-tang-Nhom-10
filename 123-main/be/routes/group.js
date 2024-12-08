const express = require("express");
const { createGroup,
    getShoppingList,
    getListByGroupId } = require("../controllers/group.js");

const router = express.Router();

// taoj Group
router.post("/create-group", createGroup);

//xem các danh sách trong Group
router.get("/ListGroupId", getShoppingList);

// // chia sẻ danh sách
router.get("/share", getListByGroupId);

module.exports = router;
