const List = require("../models/list");
const User = require("../models/user.model");
const mongoose = require("mongoose");

// Tạo danh sách mua sắm
const createList = async (req, res) => {
  try {
    const userId = res.locals.userId; // Lấy userId từ res.locals

    if (!userId) {
      return res.status(400).json({ error: "UserId is required" });
    }

    const { groupId, content } = req.body;

    if (!content || !content.name) {
      return res.status(400).json({ error: "Name is required in content" });
    }

    // Tạo một danh sách mới với model List
    const newList = new List({
      userId,
      groupId: groupId || null,
      content: {
        name: content.name, // Lưu vào content.name
        items: content.items || [], // Lưu vào content.items
      },
      workloadId: null,
    });

    // Lưu danh sách vào cơ sở dữ liệu
    await newList.save();

    // Trả về phản hồi thành công
    res.status(201).json({
      message: "List created successfully",
      data: newList,
    });
  } catch (error) {
    console.error(error);
    // Xử lý lỗi và trả về phản hồi lỗi
    res.status(500).json({
      error: "Failed to create list",
      details: error.message,
    });
  }
};

// Xem danh sách
const getListsByUserId = async (req, res) => {
  try {
    const userId = res.locals.userId; // Lấy userId từ res.locals

    if (!userId) {
      return res.status(400).json({ error: "UserId is required" });
    }

    // Tìm danh sách dựa trên userId
    const lists = await List.find({ userId });

    // Nếu không tìm thấy danh sách nào
    if (!lists || lists.length === 0) {
      return res.status(404).json({
        message: "No lists found for the provided userId",
      });
    }

    // Trả về danh sách
    res.status(200).json({
      message: "Lists retrieved successfully",
      data: lists,
    });
  } catch (error) {
    console.error(error);
    // Xử lý lỗi và trả về phản hồi lỗi
    res.status(500).json({
      error: "Failed to retrieve lists",
      details: error.message,
    });
  }
};

// Sửa danh sách
const EditList = async (req, res) => {
  try {
    const { listId } = req.params;
    const { content, groupId, workloadId } = req.body;

    if (!mongoose.Types.ObjectId.isValid(listId)) {
      return res.status(400).json({ error: "Invalid listId" });
    }

    const updatedList = await List.findByIdAndUpdate(
      listId,
      { content, groupId, workloadId },
      { new: true, runValidators: true }
    );

    if (!updatedList) {
      return res.status(404).json({ error: "List not found" });
    }

    res
      .status(200)
      .json({ message: "List updated successfully", data: updatedList });
  } catch (error) {
    res
      .status(500)
      .json({ error: "Failed to update list", details: error.message });
  }
};

// Xóa danh sách
const DeleteList = async (req, res) => {
  try {
    const userId = res.locals.userId;

    const { listId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(listId)) {
      return res.status(400).json({ error: "Invalid listId" });
    }

    const list = await List.findById(listId);
    if (!list) {
      return res.status(404).json({ error: "List not found" });
    }

    const isOwner = list.userId.toString() === userId.toString();
    if (!isOwner) {
      return res
        .status(403)
        .json({ error: "You are not the owner of this list" });
    }

    const deletedList = await List.findByIdAndDelete(listId);
    if (!deletedList) {
      return res.status(404).json({ error: "List not found" });
    }

    res.status(200).json({ message: "List deleted successfully" });
  } catch (error) {
    res
      .status(500)
      .json({ error: "Failed to delete list", details: error.message });
  }
};

// Chia sẻ danh sách
const shareList = async (req, res) => {
  try {
    const { listId } = req.params;
    const userId = res.locals.userId;

    if (!mongoose.Types.ObjectId.isValid(listId)) {
      return res.status(400).json({ error: "Invalid listId" });
    }

    // Tìm danh sách dựa trên listId
    const list = await List.findById(listId);

    if (!list) {
      return res.status(404).json({ error: "List not found" });
    }

    if (list.groupId !== null) {
      return res.status(400).json({ error: "List is already shared" });
    }

    // Tìm groupId của user
    const user = await User.findById(userId); // Giả sử bạn có model User
    if (!user || !user.groupId) {
      return res.status(200).json({ message: "User or groupId not found" });
    }

    // Cập nhật groupId của danh sách bằng groupId của user
    list.groupId = user.groupId;
    await list.save();

    res.status(200).json({ message: "List shared successfully" });
  } catch (error) {
    res
      .status(500)
      .json({ error: "Failed to share list", details: error.message });
  }
};

async function getListByGroupId(req, res) {
  const { groupId } = req.query;

  if (!groupId) {
    return res.status(400).json({ error: "groupId is required." });
  }

  try {
    const group = await Group.findById(groupId)
      .populate("member", "name email") // Populate thông tin thành viên
      .populate("ListId", "content") // Populate thông tin danh sách
      .exec();

    if (!group) {
      return res.status(404).json({ error: "group not found." });
    }

    res.status(200).json({
      groupName: group.name,
      members: group.member,
      lists: group.ListId,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}
module.exports = {
  createList,
  getListsByUserId,
  EditList,
  DeleteList,
  shareList,
  getListByGroupId,
};
