const express = require("express");
const {
  createList,
  getListsByUserId,
  EditList,
  DeleteList,
  shareList,
} = require("../controllers/list");
const authMiddleware = require("../middlewares/auth");

const router = express.Router();

router.post("/create-list", authMiddleware, createList);
router.put("/:listId/edit", authMiddleware, EditList);
router.patch("/:listId/share", authMiddleware, shareList);
router.delete("/:listId/delete", authMiddleware, DeleteList);
router.get("/getByUserId", authMiddleware, getListsByUserId);

module.exports = router;
