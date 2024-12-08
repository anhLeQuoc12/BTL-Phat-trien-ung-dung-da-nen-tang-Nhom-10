const express = require("express");
const { createList,
    List: ListDetail,
    EditList,
    DeleteList,
    shareList } = require("../controllers/list.js");
const router = express.Router();

// tạo danh sách mua sắm
router.post("/create-list",  createList);

//xem danh sách
router.get("/:listId",  ListDetail);

// // sửa danh scahs mua sắm
router.put("/:listId/edit",  EditList);

// // Xóa danh sách
router.delete("/:listId/delete",  DeleteList);

// chia sẻ danh sách
router.delete("/:listId/share",  shareList);

module.exports = router;
