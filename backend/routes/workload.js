const express = require("express");
const {
  createList,
  List: ListDetail,
  EditList,
  DeleteList,
  shareList,
} = require("../controllers/list");
const authMiddleware = require("../middlewares/auth");

const router = express.Router();

router.post("/create-list", authMiddleware, createList);
router.get("/listId/:id/edit", authMiddleware, EditList);
router.get("/listId/:Id/share", authMiddleware, shareList);
router.get("/team/delete", authMiddleware, DeleteList);

module.exports = router;
