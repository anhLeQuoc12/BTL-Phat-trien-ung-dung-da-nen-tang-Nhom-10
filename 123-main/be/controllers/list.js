const List = require("../models/list"); // Đường dẫn tới file model List
const mongoose = require("mongoose");

// Tạo danh sách mua sắm
const createList = async (req, res) => {
    try {
        const { userId, groupId, content } = req.body;
        if (!userId) {
            return res.status(400).json({ error: "UserId is required" });
        }

        const newList = new List({
            userId,
            groupId: groupId || null, // Nếu groupId không có, mặc định là null
            content,
            workloadId: null // Mặc định là null
        });
        console.log(newList)
        await newList.save();
        res.status(201).json({ message: "List created successfully", data: newList});
    } catch (error) {
        res.status(500).json({ error: "Failed to create list", details: error.message });
    }
};

// Xem danh sách
const ListDetail = async (req, res) => {
    try {
        const { listId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(listId)) {
            return res.status(400).json({ error: "Invalid listId" });
        }

        const list = await List.findById(listId);
        if (!list) {
            return res.status(404).json({ error: "List not found" });
        }

        res.status(200).json({ data: list });
    } catch (error) {
        res.status(500).json({ error: "Failed to retrieve list", details: error.message });
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

        res.status(200).json({ message: "List updated successfully", data: updatedList });
    } catch (error) {
        res.status(500).json({ error: "Failed to update list", details: error.message });
    }
};

// Xóa danh sách
const DeleteList = async (req, res) => {
    try {
        const { listId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(listId)) {
            return res.status(400).json({ error: "Invalid listId" });
        }

        const deletedList = await List.findByIdAndDelete(listId);
        if (!deletedList) {
            return res.status(404).json({ error: "List not found" });
        }

        res.status(200).json({ message: "List deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: "Failed to delete list", details: error.message });
    }
};

// Chia sẻ danh sách
const shareList = async (req, res) => {
    try {
        const { listId } = req.params;
        const { userId } = req.body; // Nhận userId từ request body

        if (!mongoose.Types.ObjectId.isValid(listId)) {
            return res.status(400).json({ error: "Invalid listId" });
        }

        if (!userId) {
            return res.status(400).json({ error: "userId is required" });
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
            return res.status(404).json({ error: "User or groupId not found" });
        }

        // Cập nhật groupId của danh sách bằng groupId của user
        list.groupId = user.groupId;
        await list.save();

        res.status(200).json({ message: "List shared successfully", data: list });
    } catch (error) {
        res.status(500).json({ error: "Failed to share list", details: error.message });
    }
};


module.exports = {
    createList,
    List: ListDetail,
    EditList,
    DeleteList,
    shareList
};
